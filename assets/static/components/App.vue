<template lang="pug">
  #main
    .md-layout
      .md-layout-item
        .logo
          <router-link style="color: #505050; text-decoration: none;" to="/">
           #logo_text
              md-icon.md-size-2x call_merge
              | MAIL STUB
          </router-link>
      .md-layout-item.pull-right(v-if="!user")
        <md-button class="md-raised md-primary" to="/login" exact>Login</md-button>
        <md-button to="/signup">Sign up</md-button>
      .md-layout-item.pull-right(v-else)
        .account_data(@mouseover="show_user_info = true" @mouseleave="show_user_info = false")
          md-icon account_circle
          | {{user_name}}


          .user-toolbar(v-show="show_user_info")
            <md-list>
              <md-list-item to="/projects">Projects</md-list-item>
              <md-list-item to="/signout">Sign Out</md-list-item>
            </md-list>
    #main-content
      router-view

</template>

<script>
import { mapState } from 'vuex';

export default {
  name: 'app',
  data: () => ({
    show_user_info: false
  }),

  methods: {
  },

  computed: {
    user(){
      return this.$store.getters.currentUser
    },
    user_name(){
      return this.$store.getters.currentUser.email.split("@")[0]
    }
  }
}
</script>

<style lang="scss">
@import '../css/app.scss';

#main {
  width: 80%;
  margin: 0 auto;
  padding-top: 20px;
  .pull-right{
    text-align: right;
  }

  .account_data{
    cursor: pointer;
    position: relative;
    //width: 150px;
    margin-top: 13px;
  }

  .user-toolbar{
    position: absolute;
    right: 0px;
  }

}
</style>
