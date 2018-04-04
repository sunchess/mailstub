// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import Vue from 'vue'
import VueResource from 'vue-resource'
import VueRouter from 'vue-router'
import Vuex from 'vuex'
import VueMaterial from 'vue-material'
//import 'vue-material/dist/vue-material.css'

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


// Import Vue components
import App from "../components/App"
import Home from "../components/Home"
import Login from "../components/Login"

Vue.config.productionTip = false

Vue.use(VueMaterial)
Vue.use(VueResource)

Vue.use(VueRouter)
Vue.http.options.root = '/api';

Vue.use(Vuex)


const router = new VueRouter({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home,
    },

    {
      path: '/login',
      name: 'login',
      component: Login,
    },
  ],
});


new Vue({
  el: '#app',
  router,
  template: '<App/>',
  components: { App }
});
