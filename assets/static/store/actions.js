export default {
  register({commit}, user){
    commit('set_current_user', user)
  }
}
