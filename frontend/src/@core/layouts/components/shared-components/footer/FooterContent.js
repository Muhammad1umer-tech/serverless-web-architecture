// ** MUI Imports
import Box from '@mui/material/Box'
import MuiLink from '@mui/material/Link'
import Typography from '@mui/material/Typography'
import useMediaQuery from '@mui/material/useMediaQuery'

const FooterContent = () => {
  // ** Var
  const hidden = useMediaQuery(theme => theme.breakpoints.down('md'))

  return (
    <div>Footer</div>
    // <Box sx={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between' }}>
    //   <Typography sx={{ mr: 2 }}>
    //     {`© ${new Date().getFullYear()}, Made with `}
    //     <Box component='span' sx={{ color: 'error.main' }}>
    //       ❤️
    //     </Box>
    //     {` by `}
    //     <MuiLink target='_blank' >
    //       AdAutomaters
    //     </MuiLink>
    //   </Typography>
    //   {hidden ? null : (
    //     <Box sx={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', '& :not(:last-child)': { mr: 4 } }}>
    //       <MuiLink target='_blank' >
    //         License
    //       </MuiLink>
    //       <MuiLink target='_blank' >
    //         More Themes
    //       </MuiLink>
    //       <MuiLink target='_blank' >
    //         Documentation
    //       </MuiLink>
    //       <MuiLink target='_blank'>
    //         Support
    //       </MuiLink>
    //     </Box>
    //   )}
    // </Box>
  )
}

export default FooterContent
