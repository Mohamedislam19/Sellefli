"""
QA Testing Suite for Delete Listing Feature - Django Backend Tests
Tests the DELETE /api/items/{id}/ endpoint with various scenarios
Run with: python manage.py test items.tests.DeleteItemTests
"""

from django.test import TestCase, Client
from rest_framework.test import APIClient, APITestCase
from rest_framework import status
from users.models import User
from items.models import Item
from item_images.models import ItemImage
import uuid
from datetime import datetime, timedelta


class DeleteItemPermissionTests(APITestCase):
    """Test delete endpoint permission checks."""
    
    def setUp(self):
        """Create test users and items."""
        self.client = APIClient()
        
        # Create user 1
        self.user1 = User.objects.create_user(
            id=uuid.uuid4(),
            username='testuser1',
            email='test1@example.com',
            phone='1234567890'
        )
        
        # Create user 2
        self.user2 = User.objects.create_user(
            id=uuid.uuid4(),
            username='testuser2',
            email='test2@example.com',
            phone='0987654321'
        )
        
        # Create item owned by user1
        self.item1 = Item.objects.create(
            id=uuid.uuid4(),
            owner=self.user1,
            title='Test Item',
            category='Electronics',
            description='Test description',
            estimated_value=100.00,
            deposit_amount=20.00,
            is_available=True
        )
    
    def test_delete_own_item_success(self):
        """TC-4.1: Owner can delete own item."""
        # Login as user1
        self.client.force_authenticate(user=self.user1)
        
        # Verify item exists
        self.assertTrue(Item.objects.filter(id=self.item1.id).exists())
        
        # Delete item
        url = f'/api/items/{self.item1.id}/'
        response = self.client.delete(url)
        
        # Check success response (204 No Content)
        self.assertEqual(
            response.status_code,
            status.HTTP_204_NO_CONTENT,
            f"Expected 204, got {response.status_code}: {response.data if response.data else ''}"
        )
        
        # Verify item is deleted
        self.assertFalse(Item.objects.filter(id=self.item1.id).exists())
    
    def test_delete_other_users_item_forbidden(self):
        """TC-4.1: Non-owner cannot delete other's item (403)."""
        # Login as user2 (not the owner)
        self.client.force_authenticate(user=self.user2)
        
        # Try to delete user1's item
        url = f'/api/items/{self.item1.id}/'
        response = self.client.delete(url)
        
        # Should get 403 Forbidden
        self.assertEqual(
            response.status_code,
            status.HTTP_403_FORBIDDEN,
            f"Expected 403, got {response.status_code}"
        )
        
        # Verify item still exists
        self.assertTrue(Item.objects.filter(id=self.item1.id).exists())
    
    def test_delete_without_authentication(self):
        """TC-4.1: Unauthenticated user cannot delete (401)."""
        # No authentication
        url = f'/api/items/{self.item1.id}/'
        response = self.client.delete(url)
        
        # Should get 401 Unauthorized
        self.assertEqual(
            response.status_code,
            status.HTTP_401_UNAUTHORIZED,
            f"Expected 401, got {response.status_code}"
        )
        
        # Verify item still exists
        self.assertTrue(Item.objects.filter(id=self.item1.id).exists())
    
    def test_delete_nonexistent_item(self):
        """TC-3.2: Delete non-existent item returns 404."""
        self.client.force_authenticate(user=self.user1)
        
        # Try to delete non-existent item
        fake_id = uuid.uuid4()
        url = f'/api/items/{fake_id}/'
        response = self.client.delete(url)
        
        # Should get 404 Not Found
        self.assertEqual(
            response.status_code,
            status.HTTP_404_NOT_FOUND,
            f"Expected 404, got {response.status_code}"
        )


class DeleteItemWithImagesTests(APITestCase):
    """Test image cleanup during deletion."""
    
    def setUp(self):
        """Create test user, item, and images."""
        self.client = APIClient()
        
        self.user = User.objects.create_user(
            id=uuid.uuid4(),
            username='imagetest',
            email='image@test.com',
            phone='1234567890'
        )
        
        self.item = Item.objects.create(
            id=uuid.uuid4(),
            owner=self.user,
            title='Item with Images',
            category='Books',
            description='Item with multiple images',
            estimated_value=50.00,
            deposit_amount=10.00,
            is_available=True
        )
        
        # Create multiple images for item
        self.image1 = ItemImage.objects.create(
            id=uuid.uuid4(),
            item=self.item,
            image_url='https://example.com/image1.jpg',
            position=1
        )
        
        self.image2 = ItemImage.objects.create(
            id=uuid.uuid4(),
            item=self.item,
            image_url='https://example.com/image2.jpg',
            position=2
        )
    
    def test_delete_item_removes_images(self):
        """TC-5.2: Images deleted when item is deleted."""
        self.client.force_authenticate(user=self.user)
        
        # Verify images exist
        self.assertEqual(ItemImage.objects.filter(item=self.item).count(), 2)
        
        # Delete item
        url = f'/api/items/{self.item.id}/'
        response = self.client.delete(url)
        
        # Check success
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        
        # Verify images are deleted
        self.assertEqual(ItemImage.objects.filter(item=self.item).count(), 0)
        
        # Verify all image IDs are gone
        self.assertFalse(ItemImage.objects.filter(id=self.image1.id).exists())
        self.assertFalse(ItemImage.objects.filter(id=self.image2.id).exists())
    
    def test_delete_multiple_times_idempotent(self):
        """TC-6.1: Double delete returns 404."""
        self.client.force_authenticate(user=self.user)
        
        url = f'/api/items/{self.item.id}/'
        
        # First delete should succeed
        response1 = self.client.delete(url)
        self.assertEqual(response1.status_code, status.HTTP_204_NO_CONTENT)
        
        # Second delete should return 404
        response2 = self.client.delete(url)
        self.assertEqual(response2.status_code, status.HTTP_404_NOT_FOUND)


class DeleteItemEdgeCasesTests(APITestCase):
    """Test edge cases and error scenarios."""
    
    def setUp(self):
        """Create test data."""
        self.client = APIClient()
        
        self.user = User.objects.create_user(
            id=uuid.uuid4(),
            username='edgetest',
            email='edge@test.com',
            phone='1234567890'
        )
        
        self.item = Item.objects.create(
            id=uuid.uuid4(),
            owner=self.user,
            title='Edge Test Item',
            category='Other',
            description='For edge case testing',
            estimated_value=75.00,
            deposit_amount=15.00,
            is_available=True
        )
    
    def test_delete_with_invalid_uuid_format(self):
        """TC-3.2: Invalid UUID format returns error."""
        self.client.force_authenticate(user=self.user)
        
        # Try invalid UUID
        url = '/api/items/not-a-uuid/'
        response = self.client.delete(url)
        
        # Should return 404 or 400
        self.assertIn(
            response.status_code,
            [status.HTTP_404_NOT_FOUND, status.HTTP_400_BAD_REQUEST],
            f"Expected 404/400, got {response.status_code}"
        )
    
    def test_delete_missing_endpoint_slash(self):
        """TC-3.1: Endpoint without trailing slash."""
        self.client.force_authenticate(user=self.user)
        
        # URL without trailing slash (Django may redirect)
        url = f'/api/items/{self.item.id}'
        response = self.client.delete(url)
        
        # May redirect or succeed
        self.assertIn(
            response.status_code,
            [status.HTTP_204_NO_CONTENT, status.HTTP_301_MOVED_PERMANENTLY],
            f"Unexpected status: {response.status_code}"
        )


class DeleteItemDatabaseIntegrityTests(APITestCase):
    """Test database consistency after deletion."""
    
    def setUp(self):
        """Create test data."""
        self.client = APIClient()
        
        self.user1 = User.objects.create_user(
            id=uuid.uuid4(),
            username='user1integrity',
            email='user1@test.com',
            phone='1111111111'
        )
        
        self.user2 = User.objects.create_user(
            id=uuid.uuid4(),
            username='user2integrity',
            email='user2@test.com',
            phone='2222222222'
        )
        
        # Create items for both users
        self.item1_u1 = Item.objects.create(
            id=uuid.uuid4(),
            owner=self.user1,
            title='User1 Item1',
            category='Test',
            description='Test',
            estimated_value=50.00,
            deposit_amount=10.00
        )
        
        self.item2_u1 = Item.objects.create(
            id=uuid.uuid4(),
            owner=self.user1,
            title='User1 Item2',
            category='Test',
            description='Test',
            estimated_value=60.00,
            deposit_amount=12.00
        )
        
        self.item1_u2 = Item.objects.create(
            id=uuid.uuid4(),
            owner=self.user2,
            title='User2 Item1',
            category='Test',
            description='Test',
            estimated_value=70.00,
            deposit_amount=14.00
        )
    
    def test_delete_only_target_item(self):
        """TC-5.1: Only target item deleted, others untouched."""
        self.client.force_authenticate(user=self.user1)
        
        # Verify 3 items exist
        self.assertEqual(Item.objects.count(), 3)
        
        # Delete user1's first item
        url = f'/api/items/{self.item1_u1.id}/'
        response = self.client.delete(url)
        
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        
        # Verify 2 items remain
        self.assertEqual(Item.objects.count(), 2)
        
        # Verify correct items remain
        self.assertFalse(Item.objects.filter(id=self.item1_u1.id).exists())
        self.assertTrue(Item.objects.filter(id=self.item2_u1.id).exists())
        self.assertTrue(Item.objects.filter(id=self.item1_u2.id).exists())
    
    def test_user_isolation_after_deletion(self):
        """TC-5.2: User A's deletion doesn't affect User B's items."""
        self.client.force_authenticate(user=self.user1)
        
        # Delete user1's item
        url = f'/api/items/{self.item1_u1.id}/'
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        
        # Switch to user2 and verify their items unchanged
        self.client.force_authenticate(user=self.user2)
        user2_items = Item.objects.filter(owner=self.user2)
        
        self.assertEqual(user2_items.count(), 1)
        self.assertTrue(user2_items.filter(id=self.item1_u2.id).exists())


# Test Running Instructions
# =======================
# Run all tests:
#   python manage.py test items.tests
#
# Run specific test class:
#   python manage.py test items.tests.DeleteItemPermissionTests
#
# Run specific test:
#   python manage.py test items.tests.DeleteItemPermissionTests.test_delete_own_item_success
#
# With verbose output:
#   python manage.py test items.tests -v 2
#
# With coverage:
#   coverage run --source='.' manage.py test items.tests
#   coverage report
