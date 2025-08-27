export default {
  // meEndpoint: '/auth/me',
  // loginEndpoint: '/jwt/login',
  meEndpoint: 'http://localhost:8000/user/auth/me/',  
  loginEndpoint: 'http://localhost:8000/user/login/',
  forgetPassword: "http://localhost:8000/user/forget-password/",
  ResetPassword: "http://localhost:8000/user/reset-password/",
  registerEndpoint: 'http://localhost:8000/user/register/',
  registerEndpointVerify: 'http://localhost:8000/user/register_verify/',
  googleLodingEndpoint: 'http://localhost:8000/user/api/auth/google/',
  retrieveConv: 'http://localhost:8000/conv/list_conversation/',
  storageTokenKeyName: 'accessToken',
  onTokenExpiration: 'logout' // logout | refreshToken
}
