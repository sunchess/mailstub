<template lang="pug">
  #login
    .error()
      <md-toolbar v-if="error" class="md-accent">
        <h5 class="md-title">{{error}}</h5>
      </md-toolbar>

    .form.md-card.md-layout-item.md-size-25.md-small-size-100(v-if="!userSaved")
      <md-field md-clearable>
        <label>Email</label>
        <md-input v-model="form.email"></md-input>
      </md-field>

      <md-field>
        <label>Password</label>
        <md-input v-model="form.password" type="password"></md-input>
      </md-field>
      <md-card-actions>
        <md-button type="submit" class="md-primary md-raised" :disabled="sending" v-on:click="saveUser">Send</md-button>
      </md-card-actions>

    .form(v-else)
      p
        | You are already signed in
</template>

<script>
export default {
  name: 'login',
  data: () => ({
    form: {
      email: null,
      password: null,
    },
    userSaved: false,
    sending: false,
    error: null
  }),
  methods: {
    saveUser() {
       this.sending = true
       this.$http.post('/api/session', this.form).then(response => {
         this.userSaved = true
         this.$store.dispatch('LOGIN', response.body)
         this.loadProjects()
         this.$router.push({name: 'home'})
       }, error => {
         // error callback
         this.sending = false
         console.log(error.body)
         this.error = error.body.message
       })
    },

    loadProjects(){
      this.$http.get('/api/projects').then(response => {
        this.$store.dispatch('SET_PROJECTS', response.body.data)
      }, error => {
        // error callback
        this.errors = error.body.errors
      })
    }
  },

  created(){
    if(this.$store.getters.currentUser){
      this.userSaved = true
    }
  }
}
</script>

<style lang="scss">
  #login{
    .error{
      width: 386px;
      margin: 0 auto;
      margin-bottom: 39px;
      height: 42px;
      h5{
        font-size: 16px
      }
    }
    .form{
      width: 300px;
      margin: 0 auto;
      padding: 10px
    }
  }
</style>
