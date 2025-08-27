// ** React Imports
import { createContext, useEffect, useState } from 'react'

// ** Next Import
import { useRouter } from 'next/router'

// ** Axios
import axios from 'axios'

// ** Config
import authConfig from 'src/configs/auth'


// ** Defaults
const defaultProvider = {
  user: null,
  loading: true,
  setUser: () => null,
  setLoading: () => Boolean,
  login: () => Promise.resolve(),
  logout: () => Promise.resolve(),
  register: () => Promise.resolve()
}
const AuthContext = createContext(defaultProvider)
import {checkAndRefreshSession} from 'src/pages/cognito';

const AuthProvider = ({ children }) => {
  console.log("haha")
  
  // ** States
  const [user, setUser] = useState(defaultProvider.user)
  const [loading, setLoading] = useState(defaultProvider.loading)

  // ** Hooks
  const router = useRouter()
  useEffect(() => {

    const checkSession = async () => {
      try {
        // Call the async function to check and refresh the session
        const response = await checkAndRefreshSession();
        console.log("response ", response);

        // Set user after successful session check/refresh
        setUser({
          email: "umer",
          firstName: "ali",
          lastName: "ahmed",
          role: "admin"
        });
        router.replace("/home")
      } catch (error) {
        console.error(error.message); // Catch any error and log it
        router.replace("/login")
      } finally {
        setLoading(false); // Set loading to false once the process is complete
      }
    };
    checkSession(); // Call the async function inside useEffect
  }, []);

   const handleLogin = (accessToken) => {
      window.localStorage.setItem(authConfig.storageTokenKeyName, accessToken)
        const returnUrl = router.query.returnUrl
        setUser({email:"umer", firstName:"ali", lastName:"ahmed", role: "admin" })
        window.localStorage.setItem('userData', JSON.stringify(user))
        const redirectURL = returnUrl && returnUrl !== '/' ? returnUrl : '/'
        router.replace(redirectURL)
  }

  const handleLogout = () => {
    setUser(null)
    window.localStorage.removeItem('userData')
    window.localStorage.removeItem(authConfig.storageTokenKeyName)
    router.push('/login')
  }

  const handleRegister = (params, errorCallback) => {
    axios
      .post(authConfig.registerEndpoint, params)
      .then(res => {
        if (res.data.error) {
          if (errorCallback) errorCallback(res.data.error)
        } else {
          handleLogin({ email: params.email, password: params.password })
        }
      })
      .catch(err => (errorCallback ? errorCallback(err) : null))
  }

  const values = {
    user,
    loading,
    setUser,
    setLoading,
    login: handleLogin,
    logout: handleLogout,
    register: handleRegister
  }

  return <AuthContext.Provider value={values}>{children}</AuthContext.Provider>
}

export { AuthContext, AuthProvider }
