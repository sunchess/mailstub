<template lang="pug">
  #login
    .form.md-card.md-layout-item.md-size-25.md-small-size-100(v-if="!userSaved")
      <span class="md-error " v-if="errors">{{errors.join(", ")}}</span>
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
    errors: null
  }),
  methods: {
    saveUser () {
       this.sending = true
       this.$http.post('/api/session', this.form).then(response => {
         this.userSaved = true
         this.$store.dispatch('LOGIN', response.body)
         this.$router.push({name: 'home'})
       }, error => {
         // error callback
         this.sending = false
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
    .form{
      width: 300px;
      margin: 0 auto;
      padding: 10px
    }
  }
</style>
