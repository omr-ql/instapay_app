# main.py
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
import string
from typing import Dict, Optional
import time
import uvicorn
from fastapi.security import OAuth2PasswordBearer


app = FastAPI(title="InstaPay API")

# Add CORS middleware to allow requests from your Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage (replace with a database in production)
users_db = {}
otp_storage: Dict[str, Dict] = {}  # {mobile_number: {"otp": "123456", "expiry": timestamp}}
tokens_db = {}  # {token: username}

# OTP Models
class OTPRequest(BaseModel):
    mobile_number: str

class OTPVerify(BaseModel):
    mobile_number: str
    otp: str

# OTP Generation and Verification Functions
def generate_otp(length=6):
    """Generate a random numeric OTP of specified length"""
    return ''.join(random.choices(string.digits, k=length))

def store_otp(mobile_number: str, otp: str):
    """Store OTP with expiry time (5 minutes from now)"""
    expiry = time.time() + 300  # 5 minutes
    otp_storage[mobile_number] = {"otp": otp, "expiry": expiry}

def verify_stored_otp(mobile_number: str, otp: str) -> bool:
    """Verify if the provided OTP matches the stored OTP and is not expired"""
    if mobile_number not in otp_storage:
        return False
    
    stored_data = otp_storage[mobile_number]
    current_time = time.time()
    
    # Check if OTP is expired
    if current_time > stored_data["expiry"]:
        del otp_storage[mobile_number]
        return False
    
    # Check if OTP matches
    if stored_data["otp"] == otp:
        del otp_storage[mobile_number]  # Remove OTP after successful verification
        return True
    
    return False

# OTP Endpoints
@app.post("/auth/send-otp")
async def send_otp(request: OTPRequest):
    mobile_number = request.mobile_number
    
    # Generate a 6-digit OTP
    otp = generate_otp()
    
    # Store OTP
    store_otp(mobile_number, otp)
    
    # In a real application, you would send the OTP via SMS using a service like Twilio
    # For development, we'll just return the OTP in the response
    print(f"OTP for {mobile_number}: {otp}")
    
    return {"message": "OTP sent successfully"}

@app.post("/auth/verify-otp")
async def verify_otp(verify_request: OTPVerify):
    mobile_number = verify_request.mobile_number
    otp = verify_request.otp
    
    if verify_stored_otp(mobile_number, otp):
        return {"verified": True}
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid OTP or OTP expired"
        )

# User Models
class UserBase(BaseModel):
    username: str
    mobile_number: str

class UserCreate(UserBase):
    password: str
    registration_type: str
    bank_account: Optional[str] = None
    wallet_provider: Optional[str] = None

class User(UserBase):
    id: str
    type: str
    bank_account: Optional[str] = None
    wallet_provider: Optional[str] = None
    balance: float = 1000.0  # Default balance for demonstration

class UserLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    token: str
    user: User

# Helper functions
def generate_id():
    """Generate a random ID for users"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=10))

def generate_token():
    """Generate a random token for authentication"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=32))

# Authentication and Registration Endpoints
@app.post("/auth/register")
async def register(user_data: UserCreate):
    # Check if username already exists
    if any(u["username"] == user_data.username for u in users_db.values()):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Check if mobile number already exists
    if any(u["mobile_number"] == user_data.mobile_number for u in users_db.values()):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Mobile number already registered"
        )
    
    # Create user
    user_id = generate_id()
    user_type = "bank" if user_data.registration_type == "bank" else "wallet"
    
    users_db[user_id] = {
        "id": user_id,
        "username": user_data.username,
        "password": user_data.password,  # In production, hash the password
        "mobile_number": user_data.mobile_number,
        "type": user_type,
        "bank_account": user_data.bank_account if user_type == "bank" else None,
        "wallet_provider": user_data.wallet_provider if user_type == "wallet" else None,
        "balance": 1000.0  # Default balance for demonstration
    }
    
    return {"message": "User registered successfully"}

@app.post("/auth/login", response_model=Token)
async def login(user_data: UserLogin):
    # Find user by username
    user = None
    user_id = None
    
    for uid, u in users_db.items():
        if u["username"] == user_data.username:
            user = u
            user_id = uid
            break
    
    if not user or user["password"] != user_data.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )
    
    # Generate token
    token = generate_token()
    tokens_db[token] = user_data.username
    
    # Create user object for response
    user_obj = User(
        id=user_id,
        username=user["username"],
        mobile_number=user["mobile_number"],
        type=user["type"],
        bank_account=user["bank_account"],
        wallet_provider=user["wallet_provider"],
        balance=user["balance"]
    )
    
    return {"token": token, "user": user_obj}

async def get_current_user(token: str = Depends(OAuth2PasswordBearer(tokenUrl="auth/login"))):
    if token not in tokens_db:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    username = tokens_db[token]
    user = None
    user_id = None
    
    for uid, u in users_db.items():
        if u["username"] == username:
            user = u
            user_id = uid
            break
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return {
        "id": user_id,
        "username": user["username"],
        "mobile_number": user["mobile_number"],
        "type": user["type"],
        "bank_account": user["bank_account"],
        "wallet_provider": user["wallet_provider"],
        "balance": user["balance"]
    }

# Transaction Models
class TransactionBase(BaseModel):
    amount: float
    description: Optional[str] = None

class InstapayTransfer(TransactionBase):
    receiver_username: str

class WalletTransfer(TransactionBase):
    mobile_number: str

class BankTransfer(TransactionBase):
    bank_account: str

class Transaction(BaseModel):
    id: str
    type: str
    amount: float
    sender_username: str
    receiver_username: Optional[str] = None
    receiver_mobile_number: Optional[str] = None
    receiver_bank_account: Optional[str] = None
    timestamp: float
    status: str
    description: Optional[str] = None

# Transactions storage
transactions_db = []

# User Balance and Transaction Endpoints
@app.get("/user/balance")
async def get_balance(current_user: dict = Depends(get_current_user)):
    return {"balance": current_user["balance"]}

@app.get("/user/transactions")
async def get_transactions(current_user: dict = Depends(get_current_user)):
    user_transactions = [
        t for t in transactions_db 
        if t["sender_username"] == current_user["username"] or 
           (t.get("receiver_username") == current_user["username"])
    ]
    return {"transactions": user_transactions}

@app.post("/transactions/instapay")
async def transfer_to_instapay(
    transfer_data: InstapayTransfer,
    current_user: dict = Depends(get_current_user)
):
    # Check if receiver exists
    receiver = None
    receiver_id = None
    
    for uid, u in users_db.items():
        if u["username"] == transfer_data.receiver_username:
            receiver = u
            receiver_id = uid
            break
    
    if not receiver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Receiver not found"
        )
    
    # Check if user has enough balance
    if current_user["balance"] < transfer_data.amount:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient balance"
        )
    
    # Update balances
    for uid, u in users_db.items():
        if uid == current_user["id"]:
            u["balance"] -= transfer_data.amount
        if uid == receiver_id:
            u["balance"] += transfer_data.amount
    
    # Create transaction record
    transaction_id = generate_id()
    transaction = {
        "id": transaction_id,
        "type": "instapay_transfer",
        "amount": transfer_data.amount,
        "sender_username": current_user["username"],
        "receiver_username": transfer_data.receiver_username,
        "timestamp": time.time(),
        "status": "completed",
        "description": transfer_data.description
    }
    
    transactions_db.append(transaction)
    
    return {"message": "Transfer successful", "transaction_id": transaction_id}

# Similar endpoints for wallet and bank transfers
@app.post("/transactions/wallet")
async def transfer_to_wallet(
    transfer_data: WalletTransfer,
    current_user: dict = Depends(get_current_user)
):
    # Check if user has enough balance
    if current_user["balance"] < transfer_data.amount:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient balance"
        )
    
    # Update balance
    for uid, u in users_db.items():
        if uid == current_user["id"]:
            u["balance"] -= transfer_data.amount
    
    # Create transaction record
    transaction_id = generate_id()
    transaction = {
        "id": transaction_id,
        "type": "wallet_transfer",
        "amount": transfer_data.amount,
        "sender_username": current_user["username"],
        "receiver_mobile_number": transfer_data.mobile_number,
        "timestamp": time.time(),
        "status": "completed",
        "description": transfer_data.description
    }
    
    transactions_db.append(transaction)
    
    return {"message": "Transfer successful", "transaction_id": transaction_id}

@app.post("/transactions/bank")
async def transfer_to_bank(
    transfer_data: BankTransfer,
    current_user: dict = Depends(get_current_user)
):
    # Check if user has enough balance
    if current_user["balance"] < transfer_data.amount:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient balance"
        )
    
    # Check if user is registered with bank account
    if current_user["type"] != "bank":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only bank account users can transfer to bank accounts"
        )
    
    # Update balance
    for uid, u in users_db.items():
        if uid == current_user["id"]:
            u["balance"] -= transfer_data.amount
    
    # Create transaction record
    transaction_id = generate_id()
    transaction = {
        "id": transaction_id,
        "type": "bank_transfer",
        "amount": transfer_data.amount,
        "sender_username": current_user["username"],
        "receiver_bank_account": transfer_data.bank_account,
        "timestamp": time.time(),
        "status": "completed",
        "description": transfer_data.description
    }
    
    transactions_db.append(transaction)
    
    return {"message": "Transfer successful", "transaction_id": transaction_id}
# Bill Models
class BillDetails(BaseModel):
    account_number: str
    type: str

class BillPayment(BaseModel):
    bill_id: str

# Bills storage
bills_db = []

# Generate some sample bills
for i in range(1, 10):
    bill_type = random.choice(["gas", "electricity", "water"])
    account_number = ''.join(random.choices(string.digits, k=10))
    customer_name = f"Customer {i}"
    amount = round(random.uniform(50, 500), 2)
    due_date = time.time() + random.randint(86400, 2592000)  # 1-30 days from now
    
    # Generate bill-specific details
    details = {}
    if bill_type == "electricity":
        details = {
            "meter_number": ''.join(random.choices(string.digits, k=8)),
            "consumption": random.randint(100, 1000),
            "rate": round(random.uniform(0.5, 2.0), 2),
            "service_fee": round(random.uniform(5, 20), 2)
        }
    elif bill_type == "water":
        details = {
            "meter_number": ''.join(random.choices(string.digits, k=8)),
            "consumption": random.randint(5, 50),
            "rate": round(random.uniform(2.0, 5.0), 2),
            "service_fee": round(random.uniform(5, 15), 2)
        }
    elif bill_type == "gas":
        details = {
            "meter_number": ''.join(random.choices(string.digits, k=8)),
            "consumption": random.randint(10, 100),
            "rate": round(random.uniform(1.0, 3.0), 2),
            "service_fee": round(random.uniform(5, 15), 2)
        }
    
    bills_db.append({
        "id": generate_id(),
        "type": bill_type,
        "account_number": account_number,
        "customer_name": customer_name,
        "amount": amount,
        "due_date": due_date,
        "is_paid": False,
        "payment_date": None,
        "details": details
    })

# Bill Endpoints
@app.get("/bills")
async def get_bills(current_user: dict = Depends(get_current_user)):
    # In a real app, you would filter bills by user
    # For demo purposes, we'll return all bills
    return {"bills": bills_db}

@app.get("/bills/details")
async def get_bill_details(
    account_number: str,
    type: str,
    current_user: dict = Depends(get_current_user)
):
    # Find bill by account number and type
    bill = None
    for b in bills_db:
        if b["account_number"] == account_number and b["type"] == type and not b["is_paid"]:
            bill = b
            break
    
    if not bill:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Bill not found or already paid"
        )
    
    return {"bill": bill}

@app.post("/bills/pay")
async def pay_bill(
    payment_data: BillPayment,
    current_user: dict = Depends(get_current_user)
):
    # Find bill by ID
    bill = None
    bill_index = -1
    
    for i, b in enumerate(bills_db):
        if b["id"] == payment_data.bill_id:
            bill = b
            bill_index = i
            break
    
    if not bill:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Bill not found"
        )
    
    if bill["is_paid"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bill already paid"
        )
    
    # Check if user has enough balance
    if current_user["balance"] < bill["amount"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient balance"
        )
    
    # Update user balance
    for uid, u in users_db.items():
        if uid == current_user["id"]:
            u["balance"] -= bill["amount"]
    
    # Update bill status
    bills_db[bill_index]["is_paid"] = True
    bills_db[bill_index]["payment_date"] = time.time()
    
    # Create transaction record
    transaction_id = generate_id()
    transaction = {
        "id": transaction_id,
        "type": "bill_payment",
        "amount": bill["amount"],
        "sender_username": current_user["username"],
        "timestamp": time.time(),
        "status": "completed",
        "description": f"Payment for {bill['type']} bill"
    }
    
    transactions_db.append(transaction)
    
    return {"message": "Bill payment successful", "transaction_id": transaction_id}
if __name__ == "__main__":

    uvicorn.run(app, host="0.0.0.0", port=8000)
