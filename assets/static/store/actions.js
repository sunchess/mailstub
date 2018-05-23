export default {
  REGISTER({commit}, user){
    commit('set_current_user', user)
  },

  LOGIN({commit}, user){
    commit('set_current_user', user)
  },

  LOGOUT({commit}){
    commit('logout')
  },

  ADD_PROJECT({commit}, project){
    commit('add_project', project)
  },

  SET_PROJECTS({commit}, projects){
    commit('set_projects', projects)
  }

}
