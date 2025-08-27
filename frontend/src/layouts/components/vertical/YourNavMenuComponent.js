// YourNavMenuComponent.js
import List from '@mui/material/List'
import ListItem from '@mui/material/ListItem'
import ListItemIcon from '@mui/material/ListItemIcon'
import ListItemText from '@mui/material/ListItemText'
import Link from 'next/link'

const YourNavMenuComponent = ({ navItems }) => {
  return (
    <List>
      {navItems.map(item => (
        <Link key={item.path} href={item.path} passHref legacyBehavior>
          <ListItem button component="a">
            {item.icon && <ListItemIcon>{item.icon}</ListItemIcon>}
            <ListItemText primary={item.title} />
          </ListItem>
        </Link>
      ))}
    </List>
  )
}

export default YourNavMenuComponent
