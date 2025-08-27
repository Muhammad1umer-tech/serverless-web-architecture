// /pages/c/[chatId].js
// ** React Imports
import { useContext } from 'react'

// ** Context Imports
import { AbilityContext } from 'src/layouts/components/acl/Can'

// ** MUI Imports
import Grid from '@mui/material/Grid'
import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import Typography from '@mui/material/Typography'
import CardContent from '@mui/material/CardContent'

import { useRouter } from 'next/router'
import { useEffect, useState } from 'react'
import axios from 'axios'

const ChatPage = () => {
  const ability = useContext(AbilityContext)
  const router = useRouter()
  const { chatId } = router.query

  const [messages, setMessages] = useState([])
  console.log("chatId ", chatId)

  return (
    <Grid container spacing={6}>
        <div>{chatId}</div>
    </Grid>
         
  )
}

export default ChatPage
