// ** React Imports
import { useEffect, useState } from 'react'

// ** Axios Import
import axios from 'axios'
import authConfig from 'src/configs/auth'


const ServerSideNavItems = () => {
  const [menuItems, setMenuItems] = useState([])
  const [loading, setLoading] = useState(false)
  useEffect(() => {
    const initAuth = async () => {
      setLoading(true)
      const storedToken = window.localStorage.getItem(authConfig.storageTokenKeyName)
      if (storedToken) {
        await axios.get(authConfig.retrieveConv, {
            headers: {
              Authorization: `Bearer ${storedToken}`
            }
          })
          .then(async conversations => {
            console.log(conversations.data)
            const updatedConversations = conversations.data.map(conv => ({
              ...conv,
              path: `/c/${conv.id}`
          }));
            setMenuItems(updatedConversations)
            setLoading(false)
          })
          .catch((e) => {
            console.log(e)
            setLoading(false)
          })
      }
    }
    initAuth()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return { menuItems, loading }
}

export default ServerSideNavItems

