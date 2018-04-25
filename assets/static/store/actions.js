export default {
  REGISTER({commit}, user){
    commit('set_current_user', user)
  },

  LOGIN({commit}, user){
    commit('set_current_user', user)
  }
}
