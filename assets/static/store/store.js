import Vue from 'vue'
import Vuex from 'vuex'
import mutations from './mutations'
import getters from './getters'
import actions from './actions'

Vue.use(Vuex)

export const store = new Vuex.Store({
  state: {
    current_user: null
  },
  actions: actions,
  mutations: mutations,
  getters: getters,
})
