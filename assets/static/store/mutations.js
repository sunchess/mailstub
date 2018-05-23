export default {
  set_current_user (state, user) {
    state.current_user = user
  },
  logout (state) {
    state.current_user = null
  },

  add_project(state, project){
    state.projects.push(project)
  },

  set_projects(state, projects){
    state.projects = projects
  }
}
