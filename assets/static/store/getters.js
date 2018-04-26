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
  }

}
