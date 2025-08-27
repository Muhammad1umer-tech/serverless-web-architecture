var AmazonCognitoIdentity = require('amazon-cognito-identity-js');

import {
    CognitoUserPool,
    CognitoUserAttribute,
    CognitoUser,
    AuthenticationDetails,
  } from 'amazon-cognito-identity-js';

var poolData = {
	UserPoolId: 'us-east-1_azAYnZ66M',
	ClientId: '559vqtdo5kcqr09adtc0lqhp3d', 
  
};
var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
  
export function signUp(email, password, firstName, lastName) {
const attributeList = [
    new CognitoUserAttribute({ Name: 'email', Value: email }),
    new CognitoUserAttribute({ Name: 'given_name', Value: firstName }),
    new CognitoUserAttribute({ Name: 'family_name', Value: lastName }),
];

return new Promise((resolve, reject) => {
    userPool.signUp(email, password, attributeList, null, (err, result) => {
        if (err) {
            // Check for specific Cognito error codes and give custom feedback
            console.log("err  --> ", err)
            let errorMessage = 'An error occurred during registration.';
            
            if (err.code === 'UsernameExistsException') {
              errorMessage = 'This email is already registered. Please try logging in.';
            } else if (err.code === 'InvalidPasswordException') {
              errorMessage = 'Your password does not meet the required strength.';
            } else if (err.code === 'InvalidParameterException') {
              errorMessage = 'Invalid input. Please check your details and try again.';
            } else if (err.code === 'LimitExceededException') {
              errorMessage = 'Too many attempts. Please try again later.';
            }
            reject(new Error(errorMessage));             
          } 
    else {
        resolve(result);
    }
    });
});
}

export function confirmSignUp(email, code) {
    return new Promise((resolve, reject) => {
        const userData = { Username: email, Pool: userPool };
        const cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);

        cognitoUser.confirmRegistration(code, true, function (err, result) {
            if (err) {
                let errorMessage = 'Something went wrong. Please try again.';

                if (err.code === 'CodeMismatchException') {
                    errorMessage = 'The verification code you entered is incorrect.';
                } else if (err.code === 'ExpiredCodeException') {
                    errorMessage = 'The verification code has expired. Please request a new one.';
                } else if (err.code === 'UserNotFoundException') {
                    errorMessage = 'No user found with this email. Please check and try again.';
                } else if (err.code === 'NotAuthorizedException') {
                    errorMessage = 'This user is already confirmed. Please log in instead.';
                } else if (err.code === 'TooManyFailedAttemptsException') {
                    errorMessage = 'Too many failed attempts. Please try again later.';
                }
                console.log("aa ",errorMessage)

                reject(new Error(errorMessage));

            } else {
                resolve(result); 
            }
        });
    });
}


export function loginUser(email, password) {
  return new Promise((resolve, reject) => {
    const authenticationDetails = new AuthenticationDetails({
      Username: email,
      Password: password,
    });
    const userData = { Username: email, Pool: userPool };
    const cognitoUser = new CognitoUser(userData);
    cognitoUser.authenticateUser(authenticationDetails, {
      onSuccess: (result) => {
        console.log('Access token: ' + result);
        resolve(result.getAccessToken().getJwtToken());
      },

      onFailure: (err) => {
        console.error('Login failed:', err);
        reject(err);
      },
    });
  });
}


export function checkAndRefreshSession() {
  return new Promise((resolve, reject) => {
    const cognitoUser = userPool.getCurrentUser();

    if (cognitoUser != null) {
        cognitoUser.getSession(function (err, session) {
            if (err) {
                reject(err); // Reject if there's an error getting the session
                return;
            }

            // Manually check expiration (in case `isExpired()` doesn't work)
            const expirationTime = session.getIdToken().getExpiration(); // Expiration from ID Token
            const currentTime = Math.floor(Date.now() / 1000); // Current time in seconds

            if (expirationTime < currentTime) {
                // Token is expired
                console.log("Token expired, refreshing...");

                cognitoUser.refreshSession(session.getRefreshToken(), function (err, newSession) {
                    if (err) {
                        reject("Error refreshing token: " + err);
                        return;
                    }
                    console.log("New session", newSession);
                    resolve(newSession); // Resolve with the new session
                });
            } else {
                // Token is still valid
                console.log("Token is still valid");
                resolve(session); // Resolve with the current session
            }
        });
    } else {
        reject("No cognito user found"); // Reject if no cognito user
    }
});
}

export function logoutUser() {
  return new Promise((resolve, reject) => {
    const cognitoUser = userPool.getCurrentUser();

    if (cognitoUser) {
      cognitoUser.signOut();
      resolve('User logged out successfully');
    } else {
      reject('No user is currently logged in');
    }
  });
}
