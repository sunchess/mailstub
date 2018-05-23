export default {
  currentUser(state) {
    return state.current_user
  },

  currentToken(state){
    if( state.current_user ){
      return state.current_user.token
    }else{
      return null
    }
  },

  currentProjects(state) {
    return state.projects
  },

  userName(state){
    if( state.current_user.email ){
      return state.current_user.email.split("@")[0]
    }else{
      return ""
    }
  }
}
