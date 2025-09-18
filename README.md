# trip-ticket

Seminar paper for the course Software Development II

## Setup Instructions

Password for `.zip` files is `fit`

After cloning the repository, do the following:

- **Extract:** `fit-build-2025-08-24-env`
- **Place the `.env` file into:** `\tripTicket\tripTicket`
- **Open `\tripTicket\tripTicket`in terminal and run the command: `docker compose up --build`**

Before using the application, please read the notes below in this README:

- **Extract:** `fit-build-2025-08-24-desktop`
- **Run** `tripticket_desktop.exe` located in the "Release" folder
- **Enter desktop credentials** which can be found in this README

- Before running the mobile application, make sure that the app does not already exist on the Android emulator; if it does, uninstall it first
- **Extract:** `fit-build-2025-08-24-mobile`
- After extraction, drag the `.apk` file from the "flutter-apk" folder and wait for the installation to complete
- Once the app is installed, launch it and enter the mobile credentials which can be found in this README

## Notes

- A new user who registers will initially not have any recommendations in the "For you" section on the mobile application. Only after purchasing travel tickets will they receive recommendations.

- A user order is considered complete once the administrator activates it. Activation means entering the order ID in the activation form on the desktop application (intended to be done in retail by scanning a QR code). At that point, the administrator is given the option to print travel tickets. Tickets can only be printed once. The administrator also has the option to reprint them later, and the print button is located in the order details. For this reason, the order ID is displayed in the details, and filtering is also done by it.

- Statistics take into account only orders with the status COMPLETE and EXPIRED, as those are the statuses where the revenue amount is final.

- Only the user who purchased tickets for a particular trip can leave a review for it, and only after that trip has ended.

- When reviewing completed trips (status COMPLETE), the administrator can also access reviews for that trip. Unwanted reviews can be removed.

- The flag icons correspond to real country codes.

- All notifications within the application are sent **exclusively via e-mail**.

## Credentials

### Desktop application

#### Administrator

- **Username:** `admin`
- **Password:** `Test123!`

### Mobile application

#### Korisnik

- **Username:** `test`
- **Password:** `Test123!`

### Stripe

- **Card number:** `4242 4242 4242 4242`
- **Expiration date:** `12/34` (arbitrary)
- **CVC:** `123` (arbitrary)
- **ZIP Code:** `12345` (arbitrary)

## RabbitMQ

- **RabbitMQ** is used for sending emails to users with notifications about actions that occur on their orders.
- It is sent in cases where an order is accepted, canceled, expired, or completed.
- Additionally, in the case of opening a support ticket, the administrator’s response is sent to the user via email.
