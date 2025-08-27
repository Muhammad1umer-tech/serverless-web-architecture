import { useState, Fragment } from 'react'
import { useRouter } from 'next/router'

// ** Next Import
import Link from 'next/link'
import axios from 'axios'
import authConfig from 'src/configs/auth'

// ** MUI Components
import Button from '@mui/material/Button'
import Divider from '@mui/material/Divider'
import Checkbox from '@mui/material/Checkbox'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import InputLabel from '@mui/material/InputLabel'
import IconButton from '@mui/material/IconButton'
import Box from '@mui/material/Box'
import FormControl from '@mui/material/FormControl'
import useMediaQuery from '@mui/material/useMediaQuery'
import OutlinedInput from '@mui/material/OutlinedInput'
import { styled, useTheme } from '@mui/material/styles'
import FormHelperText from '@mui/material/FormHelperText'
import InputAdornment from '@mui/material/InputAdornment'
import MuiFormControlLabel from '@mui/material/FormControlLabel'

// ** Icon Imports
import Icon from 'src/@core/components/icon'

// ** Third Party Imports
import * as yup from 'yup'
import { yupResolver } from '@hookform/resolvers/yup'
import { useForm, Controller } from 'react-hook-form'

// ** Layout Import
import BlankLayout from 'src/@core/layouts/BlankLayout'

// ** Hooks
import { useAuth } from 'src/hooks/useAuth'
import { useSettings } from 'src/@core/hooks/useSettings'

// ** Demo Imports
import FooterIllustrationsV2 from 'src/views/pages/auth/FooterIllustrationsV2'

import { signUp, confirmSignUp } from '../cognito'
// ---------- Updated defaultValues
const defaultValues = {
  email: '',
  firstName: '',
  lastName: '',
  password: '',
  confirmPassword: '',
  terms: false
}

// ** Styled Components
const RegisterIllustration = styled('img')(({ theme }) => ({
  zIndex: 2,
  maxHeight: 600,
  marginTop: theme.spacing(12),
  marginBottom: theme.spacing(12),
  [theme.breakpoints.down(1540)]: {
    maxHeight: 550
  },
  [theme.breakpoints.down('lg')]: {
    maxHeight: 500
  }
}))

const RightWrapper = styled(Box)(({ theme }) => ({
  width: '100%',
  [theme.breakpoints.up('md')]: {
    maxWidth: 450
  },
  [theme.breakpoints.up('lg')]: {
    maxWidth: 600
  },
  [theme.breakpoints.up('xl')]: {
    maxWidth: 750
  }
}))

const LinkStyled = styled(Link)(({ theme }) => ({
  fontSize: '0.875rem',
  textDecoration: 'none',
  color: theme.palette.primary.main
}))

const FormControlLabel = styled(MuiFormControlLabel)(({ theme }) => ({
  marginTop: theme.spacing(1.5),
  marginBottom: theme.spacing(1.75),
  '& .MuiFormControlLabel-label': {
    fontSize: '0.875rem',
    color: theme.palette.text.secondary
  }
}))

const Register = () => {
  
  // ** States
  const [showPassword, setShowPassword] = useState(false)
  
  // ** Hooks
  const router = useRouter()
  const theme = useTheme()
  const { register } = useAuth()
  const { settings } = useSettings()
  const hidden = useMediaQuery(theme.breakpoints.down('md'))
  const [isError, setIsError] = useState(false)
  const [CodeDiv, showCodeDiv] = useState(false) // Added state to toggle between forms
  const [message, setMessage] = useState(' ')
  const [loading, setLoading] = useState(false)

  // ** Vars
  const { skin } = settings

  const schema = yup.object().shape({
    email: yup.string().email().required('Email is required'),
    firstName: yup.string().required('First name is required'),
    lastName: yup.string().required('Last name is required'),
    password: yup.string().min(5, 'Password must be at least 5 characters').required('Password is required'),
    confirmPassword: yup
      .string()
      .oneOf([yup.ref('password')], 'Passwords must match')
      .required('Confirm password is required'),
    terms: yup.bool().oneOf([true], 'You must accept the privacy policy & terms'),
    code: yup.string().when("CodeDiv", {
      is: true,
      then: yup.string().required('Code is required')
    })
  })

  const {
    control,
    setError,
    handleSubmit,
    formState: { errors }
  } = useForm({
    defaultValues,
    mode: 'onBlur',
    resolver: yupResolver(schema)
  })
  const onSubmitVerify = async data => {
    console.log(data.code)
    if(data.code == ''){
      setMessage("Please enter code")
      return
    }
    setLoading(true)
    try {
        const response = await confirmSignUp(data.email, data.code)
        console.log("response ----> ", response)
        setLoading(false)
        setIsError(false)
        setMessage("Successfully verified")  // Example: Displaying a simple alert
        setTimeout(() => {
          router.push('/login')
        }, 2000)      
        // axios
        //       .post(authConfig.registerEndpointVerify,
      //     { email: data.email, password: data.password, last_name: data.lastName, first_name: data.firstName, code: data.code })
      //       .then((response) => {
      //         setLoading(false)
      //         setIsError(false)
      //         setMessage(response.data.message)  // Example: Displaying a simple alert
      //         setTimeout(() => {
      //           router.push('/login')
      //         }, 2000)
      //       })
      //       .catch((error) => {
      //         console.log(error.response?.data?.message)
      //         setLoading(false)
      //         setIsError(true)
      //         setMessage(error.response?.data?.message)  // Example: Displaying a simple alert 
      //       })

      // Show the code input after the registration attempt
    showCodeDiv(true)

      } catch (error) {
      console.log("error.message ", error.message)
      setLoading(false)
      setIsError(true)
      setMessage(error.message)
    }
  }
  const onSubmit = async data => {
    const { email, firstName, lastName, password, confirmPassword} = data

    setMessage('')
    setIsError(false)

    // if (!password || !confirmPassword) {
    //   setIsError(true)
    //   setMessage('Both password fields are required')
    //   return
    // }

    // if (password !== confirmPassword) {
    //   setIsError(true)
    //   setMessage('Passwords do not match')
    //   return
    // }

    // if (password.length < 7) {
    //   setIsError(true)
    //   setMessage('Password must be at least 7 characters long.')
    //   return
    // }
    // if (!/[A-Z]/.test(password)) {
    //   setIsError(true)
    //   setMessage('Password must include at least one uppercase letter.')
    //   return
    // }
    // if (!/[a-z]/.test(password)) {
    //   setIsError(true)
    //   setMessage('Password must include at least one lowercase letter.')
    //   return
    // }
    // if (!/[0-9]/.test(password)) {
    //   setIsError(true)
    //   setMessage('Password must include at least one number.')
    //   return
    // }
    // if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    //   setIsError(true)
    //   setMessage('Password must include at least one special character.')
    //   return
    // }

    setLoading(true)
    try {
      // const response = await axios.post(authConfig.registerEndpoint, {email, password, last_name: lastName, first_name: firstName})
      const response = await signUp(email, password, lastName, firstName)
      console.log("response -> ", response)
      setMessage('')
      setLoading(false)
      setTimeout(() => {
        showCodeDiv(true)
      }, 2000)
    } catch (error) {
      console.log("error.message ", error.message)
      setLoading(false)
      setIsError(true)
      setMessage(error.message)
    }
  }

  const imageSource =
    skin === 'bordered' ? 'auth-v2-register-illustration-bordered' : 'auth-v2-register-illustration'

  return (
    <Box className='content-right' sx={{ backgroundColor: 'background.paper' }}>
      {!hidden ? (
        <Box
          sx={{
            flex: 1,
            display: 'flex',
            position: 'relative',
            alignItems: 'center',
            borderRadius: '20px',
            justifyContent: 'center',
            backgroundColor: 'customColors.bodyBg',
            margin: theme => theme.spacing(8, 0, 8, 8)
          }}
        >
          <RegisterIllustration
            alt='register-illustration'
            src={`/images/pages/${imageSource}-${theme.palette.mode}.png`}
          />
          <FooterIllustrationsV2 />
        </Box>
      ) : null}
      <RightWrapper>
        <Box
          sx={{
            p: [6, 12],
            height: '100%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
          }}
        >
          {CodeDiv ? (
            <Box sx={{ width: '100%', maxWidth: 400 }}>
              <Box sx={{ my: 6 }}>
                <Typography sx={{ mb: 1.5, fontWeight: 500, fontSize: '1.625rem', lineHeight: 1.385 }}>
                  Adventure starts here 🚀
                </Typography>
                <Typography sx={{ color: 'text.secondary' }}>Please enter the code sent to your email!</Typography>
              </Box>
              {/* Only show Code input if CodeDiv is true */}
              <form noValidate autoComplete='off' onSubmit={handleSubmit(onSubmitVerify)}>
                <FormControl fullWidth sx={{ mb: 4 }}>
                  <Controller
                    name='code'
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        label='Enter Code'
                        placeholder='Enter Code'
                        error={Boolean(errors.code)}
                      />
                    )}
                  />
                  {message && (
                      <FormHelperText
                        sx={{
                          color: isError ? '#D32F2F' : '#388E3C', // Error = red, Success = green
                          mt: 2,
                        }}
                      >
                        {message}
                      </FormHelperText>
                    )}
                </FormControl>
                <Button fullWidth size='large' type='submit' variant='contained' sx={{ mb:2.5 }} disabled={loading}>
                {loading ? 'Submitting...' : 'Submit Code'}
                </Button>
              </form>
            </Box>
          ) : (
            <Box sx={{ width: '100%', maxWidth: 400 }}>
              {/* Regular Registration Form */}
              <Box sx={{ my: 6 }}>
                <Typography sx={{ mb: 1.5, fontWeight: 500, fontSize: '1.625rem', lineHeight: 1.385 }}>
                  Adventure starts here 🚀
                </Typography>
                <Typography sx={{ color: 'text.secondary' }}>Make your app management easy and fun!</Typography>
              </Box>
              <form noValidate autoComplete='off' onSubmit={handleSubmit(onSubmit)}>
                {/* First Name */}
                <FormControl fullWidth sx={{ mb: 4 }}>
                  <Controller
                    name='firstName'
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        label='First Name'
                        placeholder='John'
                        error={Boolean(errors.firstName)}
                      />
                    )}
                  />
                  {errors.firstName && <FormHelperText sx={{ color: 'error.main' }}>{errors.firstName.message}</FormHelperText>}
                </FormControl>

                {/* Last Name */}
                <FormControl fullWidth sx={{ mb: 4 }}>
                  <Controller
                    name='lastName'
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        label='Last Name'
                        placeholder='Doe'
                        error={Boolean(errors.lastName)}
                      />
                    )}
                  />
                  {errors.lastName && <FormHelperText sx={{ color: 'error.main' }}>{errors.lastName.message}</FormHelperText>}
                </FormControl>

                {/* Email */}
                <FormControl fullWidth sx={{ mb: 4 }}>
                  <Controller
                    name='email'
                    control={control}
                    render={({ field }) => (
                      <TextField
                        {...field}
                        label='Email'
                        placeholder='user@email.com'
                        error={Boolean(errors.email)}
                      />
                    )}
                  />
                  {errors.email && <FormHelperText sx={{ color: 'error.main' }}>{errors.email.message}</FormHelperText>}
                </FormControl>

                {/* Password */}
                <FormControl fullWidth sx={{ mb: 4 }}>
                  <InputLabel htmlFor='password' error={Boolean(errors.password)}>Password</InputLabel>
                  <Controller
                    name='password'
                    control={control}
                    render={({ field }) => (
                      <OutlinedInput
                        {...field}
                        id='password'
                        label='Password'
                        type={showPassword ? 'text' : 'password'}
                        error={Boolean(errors.password)}
                        endAdornment={
                          <InputAdornment position='end'>
                            <IconButton
                              edge='end'
                              onMouseDown={e => e.preventDefault()}
                              onClick={() => setShowPassword(!showPassword)}
                            >
                              <Icon icon={showPassword ? 'tabler:eye' : 'tabler:eye-off'} fontSize={20} />
                            </IconButton>
                          </InputAdornment>
                        }
                      />
                    )}
                  />
                  {errors.password && <FormHelperText sx={{ color: 'error.main' }}>{errors.password.message}</FormHelperText>}
                </FormControl>

                {/* Confirm Password */}
                <FormControl fullWidth sx={{ mb: 4 }}>
                  <InputLabel htmlFor='confirm-password' error={Boolean(errors.confirmPassword)}>Confirm Password</InputLabel>
                  <Controller
                    name='confirmPassword'
                    control={control}
                    render={({ field }) => (
                      <OutlinedInput
                        {...field}
                        id='confirm-password'
                        label='Confirm Password'
                        type={showPassword ? 'text' : 'password'}
                        error={Boolean(errors.confirmPassword)}
                      />
                    )}
                  />
                  {errors.confirmPassword && (
                    <FormHelperText sx={{ color: 'error.main' }}>{errors.confirmPassword.message}</FormHelperText>
                  )}
                </FormControl>

                {/* Terms Checkbox */}
                <FormControl error={Boolean(errors.terms)}>
                  <Controller
                    name='terms'
                    control={control}
                    render={({ field }) => (
                      <FormControlLabel
                        control={<Checkbox {...field} checked={field.value} />}
                        label={
                          <Fragment>
                            <Typography variant='body2' component='span'>
                              I agree to{' '}
                            </Typography>
                            <LinkStyled href='/' onClick={e => e.preventDefault()}>
                              privacy policy & terms
                            </LinkStyled>
                          </Fragment>
                        }
                      />
                    )}
                  />
                  {errors.terms ? (
                    <FormHelperText sx={{ mt: 0, mb: 3 }}>
                      {errors.terms.message}
                    </FormHelperText>
                  ) : (
                    message && (
                      <FormHelperText
                        sx={{
                          color: isError ? '#D32F2F' : '#388E3C', // Error = red, Success = green
                          mb: 2.25
                        }}
                      >
                        {message}
                      </FormHelperText>
                    )
                  )}
                </FormControl>

                <Button fullWidth size='large' type='submit' variant='contained' sx={{ mb: 4 }} disabled={loading}>
                {loading ? 'Signing Up...' : 'Sign up'}
                </Button>

                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Typography sx={{ color: 'text.secondary', mr: 2 }}>Already have an account?</Typography>
                  <Typography variant='body2'>
                    <LinkStyled href='/login'>Sign in instead</LinkStyled>
                  </Typography>
                </Box>  
              </form>
            </Box>
          )}
        </Box>
      </RightWrapper>
    </Box>
  )
}


Register.getLayout = page => <BlankLayout>{page}</BlankLayout>
Register.guestGuard = true

export default Register
