import Vue from 'vue'
import Vuex from 'vuex'
import mutations from './mutations'
import getters from './getters'
import actions from './actions'
import vuejsStorage from 'vuejs-storage'

Vue.use(Vuex)
Vue.use(vuejsStorage)

var local_storage = JSON.parse(localStorage.getItem("mailstub-namespace"))
if(local_storage){
  var current_user = local_storage.current_user
}

export const store = new Vuex.Store({
  state: {
    current_user: current_user,
    projects: []
  },
  actions: actions,
  mutations: mutations,
  getters: getters,

  plugins: [
    vuejsStorage({
      keys: ['current_user'], //keep state.current_user in localStorage
      namespace: 'mailstub-namespace'
      //storage: window.sessionStorage //if you want to use sessionStorage instead of localStorage
    })
  ]
})


