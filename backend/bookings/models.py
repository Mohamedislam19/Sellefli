

import uuid
import random
import string
from django.db import models




class BookingStatus(models.TextChoices):

    PENDING = 'pending', 'Pending'           # Initial state when borrower requests
    ACCEPTED = 'accepted', 'Accepted'        # Owner accepted the request
    ACTIVE = 'active', 'Active'              # Booking is currently in progress
    COMPLETED = 'completed', 'Completed'     # Borrower returned the item
    DECLINED = 'declined', 'Declined'        # Owner declined the request
    CLOSED = 'closed', 'Closed'              # Booking is fully closed (rated, deposit handled)


class DepositStatus(models.TextChoices):

    NONE = 'none', 'None'                    # Default - no deposit action
    RECEIVED = 'received', 'Received'        # Owner received deposit from borrower
    RETURNED = 'returned', 'Returned'        # Deposit returned to borrower
    KEPT = 'kept', 'Kept'                    # Deposit kept by owner (damage/loss)


# BOOKING MODEL

class Booking(models.Model):
   
    

    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
        help_text="Unique identifier for this booking"
    )
    
 
    
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
    

    
    booking_code = models.CharField(
        max_length=20,
        unique=True,
        null=True,
        blank=True,
        help_text="Human-readable booking reference code (e.g., SF-ABC123)"
    )
    

    start_date = models.DateField(
        help_text="When the borrowing period starts"
    )
    
    return_by_date = models.DateField(
        help_text="When the item should be returned by"
    )
    

    
    total_cost = models.DecimalField(
        max_digits=12,                        # Up to 999,999,999.99
        decimal_places=2,                     # Two decimal places for currency
        null=True,
        blank=True,
        help_text="Total rental cost in DA (Algerian Dinar)"
    )
    

    
    created_at = models.DateTimeField(
        auto_now_add=True,
        help_text="When this booking was created"
    )
    
    updated_at = models.DateTimeField(
        auto_now=True,
        help_text="When this booking was last updated"
    )
    

    
    class Meta:
        db_table = 'bookings'                 # Use existing Supabase table
        ordering = ['-created_at']            # Newest bookings first by default
        verbose_name = 'Booking'
        verbose_name_plural = 'Bookings'

    
    def __str__(self) -> str:
        return f"Booking {self.booking_code or self.id} - {self.status}"
    

    
    def generate_booking_code(self) -> str:
     
        # Generate 6 random uppercase letters and digits
        chars = string.ascii_uppercase + string.digits
        random_part = ''.join(random.choices(chars, k=6))
        code = f"SF-{random_part}"
        
        # Save the code to this booking
        self.booking_code = code
        self.save(update_fields=['booking_code', 'updated_at'])
        
        return code
    
    def accept(self) -> None:
        
        self.status = BookingStatus.ACCEPTED
        self.generate_booking_code()
        self.save(update_fields=['status', 'updated_at'])
    
    def decline(self) -> None:
   
        self.status = BookingStatus.DECLINED
        self.save(update_fields=['status', 'updated_at'])
    
    def mark_deposit_received(self) -> None:
        
        self.deposit_status = DepositStatus.RECEIVED
        self.status = BookingStatus.ACTIVE
        self.save(update_fields=['deposit_status', 'status', 'updated_at'])
    
    def mark_deposit_returned(self) -> None:
      
        self.deposit_status = DepositStatus.RETURNED
        self.status = BookingStatus.COMPLETED
        self.save(update_fields=['deposit_status', 'status', 'updated_at'])
    
    def keep_deposit(self) -> None:
       
        self.deposit_status = DepositStatus.KEPT
        self.status = BookingStatus.CLOSED
        self.save(update_fields=['deposit_status', 'status', 'updated_at'])
