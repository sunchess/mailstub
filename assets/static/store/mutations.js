export default {
  set_current_user (state, user) {
    state.current_user = user
  },
  logout (state) {
    state.current_user = null
  },
}
