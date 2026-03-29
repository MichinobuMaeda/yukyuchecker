# Deployment

[« README](../README.md)

- Firebase Console
    - Settings
        -  Usage and billing
            - Details & settings
                - Firebase billing plan
                    - Modify plan: 'Blaze'
    - Authentication
        - Sign-in method
            - Enable: 'Email/Password', 'Email link' and 'Google'
        - Templates
            - Template language: 'Japanese'
        - User account linking: 'Link accounts that use the same email'
        - Password policy
            - Enforcement mode: 'Notify enforcement'
            - Password requirement options
                - [v] Require uppercase character
                - [v] Require lowercase character
                - [v] Require special character
                - [v] Require numeric character
                - [ ] Force upgrade on sign-in
            - Password length requirements: '10'
            - Maximum password length: '4096'
    - Firestore
        - Select 'Standard edition'

- Google Cloud Console
    - APIs & Services
        - Enable Cloud Billing API

## Local

The first deployment of Functions should run from local.

```bash
> npx firebase deploy --only functions
 ... ...
⚠  functions: Since this is your first time using 2nd gen functions, we need a little bit longer to finish setting everything up. Retry the deployment in a few minutes.

> npx firebase deploy --only functions
 ... ...
✔  Deploy complete!
```

- Firebase Console
    - Authentication
        - Settings
            - Blocking functions
                - Before account creation: 'handleBeforeUserCreated'
    - Firestore
        - Start collection
            - service/version { email: "foo@bar.baz" }
