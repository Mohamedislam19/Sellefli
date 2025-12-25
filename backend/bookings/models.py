"""
=============================================================================
BOOKING MODELS - Django ORM Model for Bookings/Requests/Orders
=============================================================================

This file defines the Booking model that maps to the 'bookings' table in your
Supabase PostgreSQL database. It mirrors the Flutter Booking model exactly.

KEY CONCEPTS FOR DJANGO BEGINNERS:
----------------------------------
1. A MODEL is a Python class that represents a database table.
   Each attribute of the class = a column in the table.

2. Django ORM (Object-Relational Mapper) lets you interact with the database
   using Python code instead of raw SQL.

3. ForeignKey creates a relationship between tables (like owner_id → users.id).

4. 'choices' in a field restricts values to a predefined list (like enums).

5. 'db_table' in Meta tells Django to use an existing table name instead of
   creating a new one with the app prefix (e.g., 'bookings' not 'bookings_booking').

HOW THIS CONNECTS TO FLUTTER:
-----------------------------
- The Booking model here matches booking_model.dart in Flutter.
- Field names use snake_case (Python/DB convention) which matches your Flutter
  model's JSON keys (item_id, owner_id, etc.).
- The Flutter app currently uses Supabase directly, but this Django backend
  provides REST API endpoints that can replace or complement Supabase calls.
=============================================================================
"""

import uuid
import random
import string
from django.db import models


# =============================================================================
# BOOKING STATUS CHOICES
# =============================================================================
# These match the BookingStatus enum in Flutter's booking_model.dart:
#   pending, accepted, active, completed, declined, closed
#
# In Django, we define choices as a tuple of (value, human_readable_label).
# The 'value' is what gets stored in the database.
# =============================================================================

class BookingStatus(models.TextChoices):
    """
    Enum-like choices for booking status.
    
    Usage in code:
        booking.status = BookingStatus.PENDING
        if booking.status == BookingStatus.ACCEPTED:
            ...
    
    Values stored in DB: 'pending', 'accepted', 'active', etc.
    """
    PENDING = 'pending', 'Pending'           # Initial state when borrower requests
    ACCEPTED = 'accepted', 'Accepted'        # Owner accepted the request
    ACTIVE = 'active', 'Active'              # Booking is currently in progress
    COMPLETED = 'completed', 'Completed'     # Borrower returned the item
    DECLINED = 'declined', 'Declined'        # Owner declined the request
    CLOSED = 'closed', 'Closed'              # Booking is fully closed (rated, deposit handled)


class DepositStatus(models.TextChoices):
    """
    Enum-like choices for deposit status.
    
    Tracks the lifecycle of the security deposit:
    - none: No deposit action taken yet
    - received: Owner confirmed they received the deposit from borrower
    - returned: Owner returned the deposit to borrower (item returned safely)
    - kept: Owner kept the deposit (item damaged or not returned)
    """
    NONE = 'none', 'None'                    # Default - no deposit action
    RECEIVED = 'received', 'Received'        # Owner received deposit from borrower
    RETURNED = 'returned', 'Returned'        # Deposit returned to borrower
    KEPT = 'kept', 'Kept'                    # Deposit kept by owner (damage/loss)


# =============================================================================
# BOOKING MODEL
# =============================================================================

class Booking(models.Model):
    """
    The Booking model represents a rental/borrowing transaction between two users.
    
    This is the SAME data structure as:
    - Flutter: lib/src/data/models/booking_model.dart
    - Supabase: 'bookings' table
    
    A booking connects:
    - An ITEM (what is being borrowed)
    - An OWNER (who owns the item)
    - A BORROWER (who wants to borrow the item)
    
    The booking goes through a lifecycle:
    1. Borrower creates a booking request → status = 'pending'
    2. Owner accepts or declines → status = 'accepted' or 'declined'
    3. If accepted, deposit is handled → deposit_status = 'received'
    4. Borrower uses the item → status = 'active'
    5. Borrower returns item → status = 'completed'
    6. Owner returns/keeps deposit → deposit_status = 'returned' or 'kept'
    7. Both users can rate → status = 'closed'
    """
    
    # -------------------------------------------------------------------------
    # PRIMARY KEY
    # -------------------------------------------------------------------------
    # UUIDField: A unique identifier using UUID format (e.g., 550e8400-e29b-41d4-a716-446655440000)
    # primary_key=True: This is the main identifier for the record
    # default=uuid.uuid4: Auto-generate a new UUID when creating a booking
    # editable=False: Don't allow manual editing of this field
    # -------------------------------------------------------------------------
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
        help_text="Unique identifier for this booking"
    )
    
    # -------------------------------------------------------------------------
    # FOREIGN KEY RELATIONSHIPS
    # -------------------------------------------------------------------------
    # ForeignKey: Creates a link to another table (like a pointer)
    # on_delete=models.CASCADE: If the referenced record is deleted, delete this booking too
    # related_name: Allows reverse lookups (e.g., user.bookings_as_owner.all())
    # db_column: Specifies the actual column name in the database (matches Supabase schema)
    # -------------------------------------------------------------------------
    
    # Link to the Item being borrowed
    item = models.ForeignKey(
        'items.Item',                         # References the Item model in items app
        on_delete=models.CASCADE,             # Delete booking if item is deleted
        related_name='bookings',              # item.bookings.all() gets all bookings for an item
        db_column='item_id',                  # Column name in DB (matches Flutter model)
        help_text="The item being borrowed"
    )
    
    # Link to the Owner (the user who owns the item)
    owner = models.ForeignKey(
        'users.User',                         # References the User model in users app
        on_delete=models.CASCADE,             # Delete booking if owner is deleted
        related_name='bookings_as_owner',     # user.bookings_as_owner.all() gets bookings where user is owner
        db_column='owner_id',                 # Column name in DB
        help_text="The user who owns the item"
    )
    
    # Link to the Borrower (the user who wants to borrow)
    borrower = models.ForeignKey(
        'users.User',                         # References the User model
        on_delete=models.CASCADE,             # Delete booking if borrower is deleted
        related_name='bookings_as_borrower',  # user.bookings_as_borrower.all() gets bookings where user borrowed
        db_column='borrower_id',              # Column name in DB
        help_text="The user who is borrowing the item"
    )
    
    # -------------------------------------------------------------------------
    # STATUS FIELDS
    # -------------------------------------------------------------------------
    # CharField with choices: Stores a string but only allows predefined values
    # max_length: Maximum number of characters (must accommodate longest choice)
    # choices: The list of valid options (from our TextChoices classes above)
    # default: Value used when creating a new record without specifying this field
    # -------------------------------------------------------------------------
    
    status = models.CharField(
        max_length=20,
        choices=BookingStatus.choices,        # Only allow values from BookingStatus
        default=BookingStatus.PENDING,        # New bookings start as 'pending'
        help_text="Current status of the booking (pending, accepted, active, etc.)"
    )
    
    deposit_status = models.CharField(
        max_length=20,
        choices=DepositStatus.choices,        # Only allow values from DepositStatus
        default=DepositStatus.NONE,           # No deposit action by default
        help_text="Status of the security deposit (none, received, returned, kept)"
    )
    
    # -------------------------------------------------------------------------
    # BOOKING CODE
    # -------------------------------------------------------------------------
    # A human-readable code for the booking (e.g., "SF-ABC123")
    # Used for reference in conversations, receipts, etc.
    # null=True, blank=True: This field is optional (can be empty)
    # unique=True: No two bookings can have the same code
    # -------------------------------------------------------------------------
    
    booking_code = models.CharField(
        max_length=20,
        unique=True,
        null=True,
        blank=True,
        help_text="Human-readable booking reference code (e.g., SF-ABC123)"
    )
    
    # -------------------------------------------------------------------------
    # DATE FIELDS
    # -------------------------------------------------------------------------
    # DateField: Stores a date (year, month, day) without time
    # These define the rental period
    # -------------------------------------------------------------------------
    
    start_date = models.DateField(
        help_text="When the borrowing period starts"
    )
    
    return_by_date = models.DateField(
        help_text="When the item should be returned by"
    )
    
    # -------------------------------------------------------------------------
    # COST FIELD
    # -------------------------------------------------------------------------
    # DecimalField: For precise monetary values (no floating-point errors)
    # max_digits: Total number of digits (including decimals)
    # decimal_places: Number of digits after the decimal point
    # null=True, blank=True: Cost is optional (calculated or entered later)
    # -------------------------------------------------------------------------
    
    total_cost = models.DecimalField(
        max_digits=12,                        # Up to 999,999,999.99
        decimal_places=2,                     # Two decimal places for currency
        null=True,
        blank=True,
        help_text="Total rental cost in DA (Algerian Dinar)"
    )
    
    # -------------------------------------------------------------------------
    # TIMESTAMP FIELDS
    # -------------------------------------------------------------------------
    # auto_now_add=True: Automatically set to current time when record is CREATED
    # auto_now=True: Automatically set to current time when record is UPDATED
    # -------------------------------------------------------------------------
    
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When this booking was created"
    )
    
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When this booking was last updated"
    )
    
    # -------------------------------------------------------------------------
    # META CLASS
    # -------------------------------------------------------------------------
    # Meta: Configuration options for the model
    # db_table: Use this exact table name in DB (matches Supabase 'bookings' table)
    # ordering: Default sort order when querying (newest first)
    # -------------------------------------------------------------------------
    
    class Meta:
        db_table = 'bookings'                 # Use existing Supabase table
        ordering = ['-created_at']            # Newest bookings first by default
        verbose_name = 'Booking'
        verbose_name_plural = 'Bookings'
    
    # -------------------------------------------------------------------------
    # STRING REPRESENTATION
    # -------------------------------------------------------------------------
    # __str__: What gets shown when you print a booking object
    # Useful for Django admin and debugging
    # -------------------------------------------------------------------------
    
    def __str__(self) -> str:
        return f"Booking {self.booking_code or self.id} - {self.status}"
    
    # -------------------------------------------------------------------------
    # CUSTOM METHODS
    # -------------------------------------------------------------------------
    # You can add helper methods to the model for common operations
    # -------------------------------------------------------------------------
    
    def generate_booking_code(self) -> str:
        """
        Generate a unique human-readable booking code.
        
        Format: SF-XXXXXX (e.g., SF-A3B7K2)
        - SF = Sellefli prefix
        - 6 random alphanumeric characters
        
        This is called when the booking is accepted to create a reference code.
        """
        # Generate 6 random uppercase letters and digits
        chars = string.ascii_uppercase + string.digits
        random_part = ''.join(random.choices(chars, k=6))
        code = f"SF-{random_part}"
        
        # Save the code to this booking
        self.booking_code = code
        self.save(update_fields=['booking_code', 'updated_at'])
        
        return code
    
    def accept(self) -> None:
        """
        Accept this booking request.
        
        Called when the item owner approves a borrower's request.
        - Changes status from 'pending' to 'accepted'
        - Generates a booking code for reference
        """
        self.status = BookingStatus.ACCEPTED
        self.generate_booking_code()
        self.save(update_fields=['status', 'updated_at'])
    
    def decline(self) -> None:
        """
        Decline this booking request.
        
        Called when the item owner rejects a borrower's request.
        """
        self.status = BookingStatus.DECLINED
        self.save(update_fields=['status', 'updated_at'])
    
    def mark_deposit_received(self) -> None:
        """
        Mark that the owner has received the deposit from the borrower.
        
        This should be called when the physical/cash deposit exchange happens.
        Also moves booking to 'active' status (borrowing period begins).
        
        Matches Flutter cubit's markDepositReceived() which:
        1. Updates deposit_status to 'received'
        2. Updates booking status to 'active'
        """
        self.deposit_status = DepositStatus.RECEIVED
        self.status = BookingStatus.ACTIVE
        self.save(update_fields=['deposit_status', 'status', 'updated_at'])
    
    def mark_deposit_returned(self) -> None:
        """
        Mark that the owner has returned the deposit to the borrower.
        
        Called when the item is returned safely and deposit is given back.
        Also marks the booking as completed.
        """
        self.deposit_status = DepositStatus.RETURNED
        self.status = BookingStatus.COMPLETED
        self.save(update_fields=['deposit_status', 'status', 'updated_at'])
    
    def keep_deposit(self) -> None:
        """
        Mark that the owner is keeping the deposit.
        
        Called when the item was damaged or not returned.
        Also marks the booking as closed.
        """
        self.deposit_status = DepositStatus.KEPT
        self.status = BookingStatus.CLOSED
        self.save(update_fields=['deposit_status', 'status', 'updated_at'])

