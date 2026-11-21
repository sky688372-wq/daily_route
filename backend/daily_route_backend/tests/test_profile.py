"""SQLite로 검증하며 실제 MySQL과 사용자 데이터를 사용하지 않습니다."""
import importlib.util
import os
from pathlib import Path
import unittest
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

os.environ['DB_PASSWORD'] = 'isolated-test-password'
os.environ['JWT_SECRET'] = 'isolated-test-key-not-used-by-real-app-123456789'
spec = importlib.util.spec_from_file_location(
    'profile_test_app', Path(__file__).resolve().parents[1] / 'app' / 'main.py'
)
api = importlib.util.module_from_spec(spec)
spec.loader.exec_module(api)
api.engine.dispose()
api.engine = create_engine('sqlite://', connect_args={'check_same_thread': False}, poolclass=StaticPool)
api.SessionLocal = sessionmaker(bind=api.engine, expire_on_commit=False)


class ProfileTests(unittest.TestCase):
    def setUp(self):
        api.Base.metadata.drop_all(api.engine)
        api.Base.metadata.create_all(api.engine)
        self.client = TestClient(api.app)
        for email, name in [('first@example.com', '첫번째'), ('second@example.com', '두번째')]:
            self.assertEqual(self.client.post('/api/auth/signup', json={
                'email': email, 'nickname': name, 'password': 'initial-password',
            }).status_code, 201)
        response = self.login('first@example.com', 'initial-password')
        self.headers = {'Authorization': 'Bearer ' + response.json()['data']['access_token']}

    def login(self, email, password):
        return self.client.post('/api/auth/login', json={'email': email, 'password': password})

    def test_authentication_required(self):
        self.assertEqual(self.client.get('/api/users/me').status_code, 401)
        self.assertEqual(self.client.patch('/api/users/me', json={'nickname': '변경닉네임'}).status_code, 401)
        self.assertEqual(self.client.patch('/api/users/me/password', json={
            'current_password': 'initial-password', 'new_password': 'changed-password',
        }).status_code, 401)

    def test_invalid_token_rejected(self):
        self.assertEqual(self.client.patch('/api/users/me', headers={
            'Authorization': 'Bearer invalid-token',
        }, json={'nickname': '변경닉네임'}).status_code, 401)

    def test_expired_token_rejected(self):
        from datetime import datetime, timedelta, timezone
        token = api.jwt.encode({
            'sub': '1', 'iat': datetime.now(timezone.utc) - timedelta(days=2),
            'exp': datetime.now(timezone.utc) - timedelta(days=1),
            'iss': 'daily-route', 'aud': 'daily-route-app',
        }, api.settings.jwt_secret, algorithm='HS256')
        self.assertEqual(self.client.patch('/api/users/me', headers={
            'Authorization': 'Bearer ' + token,
        }, json={'nickname': '변경닉네임'}).status_code, 401)

    def test_update_only_current_user(self):
        result = self.client.patch('/api/users/me', headers=self.headers, json={
            'nickname': '  새닉네임  ', 'id': 2, 'email': 'changed@example.com',
        })
        self.assertEqual(result.status_code, 200)
        self.assertEqual(result.json()['data']['nickname'], '새닉네임')
        self.assertEqual(result.json()['data']['email'], 'first@example.com')
        self.assertEqual(self.client.get('/api/users/me', headers=self.headers).json()['data']['nickname'], '새닉네임')
        with api.SessionLocal() as db:
            other = db.scalar(select(api.User).where(api.User.email == 'second@example.com'))
            self.assertEqual(other.nickname, '두번째')

    def test_invalid_nickname_does_not_change_profile(self):
        for value in [' ', '가', '가' * 21]:
            self.assertEqual(self.client.patch('/api/users/me', headers=self.headers, json={'nickname': value}).status_code, 400)
        self.assertEqual(self.client.get('/api/users/me', headers=self.headers).json()['data']['nickname'], '첫번째')

    def test_wrong_current_password(self):
        result = self.client.patch('/api/users/me/password', headers=self.headers, json={
            'current_password': 'wrong-password', 'new_password': 'changed-password',
        })
        self.assertEqual(result.status_code, 400)
        self.assertTrue(self.login('first@example.com', 'initial-password').json()['success'])

    def test_invalid_new_password(self):
        for value in ['initial-password', 'short', 'x' * 65]:
            result = self.client.patch('/api/users/me/password', headers=self.headers, json={
                'current_password': 'initial-password', 'new_password': value,
            })
            self.assertEqual(result.status_code, 400)
            self.assertNotIn('initial-password', result.text)

    def test_password_change_and_login(self):
        result = self.client.patch('/api/users/me/password', headers=self.headers, json={
            'current_password': 'initial-password', 'new_password': 'changed-password',
        })
        self.assertTrue(result.json()['success'])
        self.assertEqual(self.login('first@example.com', 'initial-password').status_code, 401)
        self.assertEqual(self.login('first@example.com', 'changed-password').status_code, 200)
        self.assertEqual(self.login('second@example.com', 'initial-password').status_code, 200)
        with api.SessionLocal() as db:
            user = db.scalar(select(api.User).where(api.User.email == 'first@example.com'))
            self.assertNotEqual(user.password_hash, 'changed-password')
            self.assertTrue(api.password_hash.verify('changed-password', user.password_hash))
        self.assertNotIn('changed-password', result.text)


if __name__ == '__main__':
    unittest.main()
