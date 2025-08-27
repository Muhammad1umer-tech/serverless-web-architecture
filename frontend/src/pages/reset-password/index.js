import { useState, useEffect } from 'react'
import { useRouter } from 'next/router'
import axios from 'axios'

// ** MUI Components
import Button from '@mui/material/Button'
import TextField from '@mui/material/TextField'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'
import useMediaQuery from '@mui/material/useMediaQuery'
import { styled, useTheme } from '@mui/material/styles'
import FormHelperText from '@mui/material/FormHelperText'

// ** Icon Imports
import Icon from 'src/@core/components/icon'

// ** Layout Import
import BlankLayout from 'src/@core/layouts/BlankLayout'

// ** Demo Imports
import FooterIllustrationsV2 from 'src/views/pages/auth/FooterIllustrationsV2'

// ** Configs
import authConfig from 'src/configs/auth'

// Styled Components
const ForgotPasswordIllustration = styled('img')(({ theme }) => ({
  zIndex: 2,
  maxHeight: 650,
  marginTop: theme.spacing(12),
  marginBottom: theme.spacing(12),
  [theme.breakpoints.down(1540)]: { maxHeight: 550 },
  [theme.breakpoints.down('lg')]: { maxHeight: 500 }
}))

const RightWrapper = styled(Box)(({ theme }) => ({
  width: '100%',
  [theme.breakpoints.up('md')]: { maxWidth: 450 },
  [theme.breakpoints.up('lg')]: { maxWidth: 600 },
  [theme.breakpoints.up('xl')]: { maxWidth: 750 }
}))

import Link from 'next/link'

const LinkStyled = styled('a')(({ theme }) => ({
  display: 'flex',
  fontSize: '1rem',
  alignItems: 'center',
  textDecoration: 'none',
  justifyContent: 'center',
  color: theme.palette.primary.main
}))

const ResetPassword = () => {
  // ** Hooks
  const theme = useTheme()
  const router = useRouter()
  const { token } = router.query
  const hidden = useMediaQuery(theme.breakpoints.down('md'))

  // ** State
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [message, setMessage] = useState('')
  const [isError, setIsError] = useState(false)
  const [loading, setLoading] = useState(false)

  const handleNewPasswordChange = e => setNewPassword(e.target.value)
  const handleConfirmPasswordChange = e => setConfirmPassword(e.target.value)

  const handleSubmit = async e => {
    e.preventDefault()
    setMessage('') // Clear previous message
    setIsError(false)
  
    if (!newPassword || !confirmPassword) {
      setIsError(true)
      setMessage('Both password fields are required')
      return
    }
  
    if (newPassword !== confirmPassword) {
      setIsError(true)
      setMessage('Passwords do not match')
      return
    }
  
    // Password Validation Checks
    if (newPassword.length < 7) {
      setIsError(true)
      setMessage('Password must be at least 7 characters long.')
      return
    }
    if (!/[A-Z]/.test(newPassword)) {
      setIsError(true)
      setMessage('Password must include at least one uppercase letter.')
      return
    }
    if (!/[a-z]/.test(newPassword)) {
      setIsError(true)
      setMessage('Password must include at least one lowercase letter.')
      return
    }
    if (!/[0-9]/.test(newPassword)) {
      setIsError(true)
      setMessage('Password must include at least one number.')
      return
    }
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(newPassword)) {
      setIsError(true)
      setMessage('Password must include at least one special character.')
      return
    }
  
    setLoading(true)
  
    try {
      const response = await axios.post(authConfig.ResetPassword, { token, new_password: newPassword })
  
      setLoading(false)
      setIsError(false)
      setMessage(response.data.message || 'Password reset successful! Redirecting...')
      
      // Redirect to login after a short delay
      setTimeout(() => {
        router.push('/login')
      }, 2000)
  
    } catch (error) {
      setLoading(false)
      setIsError(true)
      setMessage(error.response?.data?.message || 'Something went wrong. Please try again.')
    }
  }
  return (
    <Box className="content-right" sx={{ backgroundColor: 'background.paper' }}>
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
          <ForgotPasswordIllustration
            alt="reset-password-illustration"
            src={`/images/pages/auth-v2-forgot-password-illustration-${theme.palette.mode}.png`}
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
          <Box sx={{ width: '100%', maxWidth: 400 }}>
            <svg width={34} height={23.375} viewBox="0 0 32 22" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                fill={theme.palette.primary.main}
                d="M0.00172773 0V6.85398C0.00172773 6.85398 -0.133178 9.01207 1.98092 10.8388L13.6912 21.9964L19.7809 21.9181L18.8042 9.88248L16.4951 7.17289L9.23799 0H0.00172773Z"
              />
            </svg>
            <Box sx={{ my: 6 }}>
              <Typography sx={{ mb: 1.5, fontWeight: 500, fontSize: '1.625rem', lineHeight: 1.385 }}>
                Reset Your Password 🔒
              </Typography>
              <Typography sx={{ color: 'text.secondary' }}>
                Enter a new password to reset your account password
              </Typography>
            </Box>
            <form noValidate autoComplete="off" onSubmit={handleSubmit}>
              <TextField
                type="password"
                label="New Password"
                value={newPassword}
                onChange={handleNewPasswordChange}
                sx={{ display: 'flex', mb: 2 }}
                required
              />
              <TextField
                type="password"
                label="Confirm Password"
                value={confirmPassword}
                onChange={handleConfirmPasswordChange}
                sx={{ display: 'flex', mb: 2 }}
                required
              />
              
              {/* Message */}
              {message && (
                <FormHelperText
                  sx={{
                    color: isError ? '#D32F2F' : '#388E3C', // Error = red, Success = green
                    mb: 3
                  }}
                >
                  {message}
                </FormHelperText>
              )}
              
              <Button fullWidth size="large" type="submit" variant="contained" sx={{ mb: 4 }} disabled={loading}>
                {loading ? 'Resetting...' : 'Reset Password'}
              </Button>
              <Typography sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', '& svg': { mr: 1 } }}>
                <LinkStyled href="/login">
                  <Icon fontSize="1.25rem" icon="tabler:chevron-left" />
                  <span>Back to login</span>
                </LinkStyled>
              </Typography>
            </form>
          </Box>
        </Box>
      </RightWrapper>
    </Box>
  )
}

ResetPassword.getLayout = page => <BlankLayout>{page}</BlankLayout>
ResetPassword.guestGuard = true

export default ResetPassword
