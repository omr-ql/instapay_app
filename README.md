# 📱 InstaPay

A full-featured mobile application built with Flutter that connects to a FastAPI backend to enable secure user authentication, OTP verification, money transfers, and utility bill payments.

## Project Structure

```
instapay/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_routes.dart
│   │   │   └── constants.dart
│   │   └── services/
│   │       ├── api_service.dart
│   │       ├── auth_service.dart
│   │       └── otp_service.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── transaction_model.dart
│   │   └── bill_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   └── bill_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── transactions/
│   │   └── bills/
│   ├── widgets/
│   └── utils/
│   └── backend_instapay/
│       ├── main.py                  # FastAPI application entry point
│       ├── requirements.txt         # Project dependencies
│       ├── README.md                # Project documentation
│       └── tests/                   # Test directory
```

## Key Components

### Authentication Screens

- Login screen with username/password authentication
- Registration screen for bank account or mobile wallet users
- OTP verification screen

### Dashboard Screens

- Home screen showing balance and quick access
- Profile screen for settings and info

### Transaction Screens

- Transfer to InstaPay accounts
- Transfer to bank accounts (bank users only)
- Transfer to mobile wallets
- Transaction history

### Bill Payment Screens

- Pay electricity, water, and gas bills
- View bill history and details

## Integration with Backend

- **api_service.dart** connects Flutter app with FastAPI backend
- JWT token-based authentication
- Real-time OTP verification
- Secure and fast transfers and payments

## Payment Gateway Integration

Consider integrating gateways like **Flutterwave**:
- Use WebView for payment checkout
- Handle payment success callbacks

## Flutter-Specific Implementation

- **Provider** for state management
- **Custom widgets** for consistent UI/UX
- **Form validation** and **secure storage**
- **WebView** for external payments



A **FastAPI** backend for an InstaPay mobile payment application that supports user authentication, OTP verification, money transfers, and bill payments.

---

## ✨ Features

- 🔐 **User Authentication**: Secure signup and login with JWT tokens
- 🔑 **OTP Verification**: Mobile number verification using one-time passwords
- 💸 **Money Transfers**: Transfer funds to other InstaPay accounts, bank accounts, or mobile wallets
- 🧾 **Bill Payments**: Pay utility bills (Electricity, Water, Gas)
- 📊 **Transaction History**: Track all financial transactions
- 💰 **Balance Management**: View and manage account balance

---

## 🛠 Tech Stack

- 📱 **Flutter** - Beautiful Widgets that interact with the user
- ⚡ **FastAPI** – High-performance API framework
- 🧩 **Pydantic** – Data validation and settings management
- 🔄 **Uvicorn** – ASGI server for running the application
- 🛡️ **JWT** – Token-based authentication

---

## 🚀 Getting Started

### ✅ Prerequisites

- Python 3.8 or higher
- pip (Python package installer)
- Flutter 3.27 or higher

### 📦 Installation

Clone the repository:

```bash
git clone https://github.com/omr_ql/instapay_app.git
cd instapay-api
```

Create and activate a virtual environment:

```bash
# On Windows
python -m venv venv
venv\Scripts\activate

# On macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

---

### ▶️ Running the Application

Start the FastAPI server:

```bash
uvicorn main:app --reload
```

The API will be available at:  
📍 `http://127.0.0.1:8000`

---

## 📚 API Documentation

- 🧪 **Swagger UI**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- 📘 **ReDoc**: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

---

## 🔌 API Endpoints

### 🔐 Authentication
- `POST /auth/register`: Register a new user
- `POST /auth/login`: Authenticate a user and get a token
- `POST /auth/send-otp`: Send OTP to a mobile number
- `POST /auth/verify-otp`: Verify OTP for a mobile number

### 👤 User Operations
- `GET /user/balance`: Get user's current balance
- `GET /user/transactions`: Get user's transaction history

### 💳 Transactions
- `POST /transactions/instapay`: Transfer to another InstaPay account
- `POST /transactions/wallet`: Transfer to a mobile wallet
- `POST /transactions/bank`: Transfer to a bank account

### 💡 Bills
- `GET /bills`: Get all bills
- `GET /bills/details`: Get details of a specific bill
- `POST /bills/pay`: Pay a bill


---

## ➕ Adding New Features

- Define new models in the appropriate `models/` or `schemas/` section
- Create new endpoints in `api/` with proper authentication
- Connect to a real database instead of in-memory storage
- Add unit tests to ensure new functionality is working

---

## 🔗 Connecting with the Flutter App

- Update the `baseUrl` in your Flutter app's API service to point to this backend
- Ensure all API calls include the proper authentication headers (JWT)
- Handle API responses and errors gracefully in the UI

---

## 🛡️ Production Considerations

- Use a real database (e.g., PostgreSQL, MongoDB)
- Implement password hashing and salting
- Integrate a real SMS gateway for OTP delivery
- Use HTTPS with SSL certificates
- Implement rate limiting and input sanitization
- Set up proper logging and monitoring (e.g., Sentry, Prometheus)

---

## 📄 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- [Flutter] (https://https://flutter.dev/)
- [FastAPI](https://fastapi.tiangolo.com/)
- [Pydantic](https://pydantic-docs.helpmanual.io/)
- [Uvicorn](https://www.uvicorn.org/)
