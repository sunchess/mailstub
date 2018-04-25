<template lang="pug">
  #sign_up
    .form.md-card.md-layout-item.md-size-25.md-small-size-100(v-if="!userSaved")
      <md-field v-bind:class="{'md-invalid': errors.email}">
        <label>Email</label>
        <md-input v-model="form.email"></md-input>
        <span class="md-error " v-if="errors.email">{{errors.email.join(", ")}}</span>
      </md-field>

      <md-field v-bind:class="{'md-invalid': errors.password}">
        <label>Password</label>
        <md-input v-model="form.password" type="password"></md-input>
        <span class="md-error " v-if="errors.password">{{errors.password.join(", ")}}</span>
      </md-field>

      <md-field v-bind:class="{'md-invalid': errors.password_confirmation}">
        <label>Retype Password</label>
        <md-input v-model="form.password_confirmation" type="password"></md-input>
        <span class="md-error " v-if="errors.password_confirmation">{{errors.password_confirmation.join(", ")}}</span>
      </md-field>

      <md-card-actions>
        <md-button type="submit" class="md-primary md-raised" :disabled="sending" v-on:click="saveUser">Send</md-button>
      </md-card-actions>
    .form(v-else)
      p
        | You are already registered
</template>

<script>
export default {
  name: 'sign_up',
  data: () => ({
    form: {
      email: null,
      password: null,
      password_confirmation: null,
    },
    errors: {
      email: null,
      password: null,
      password_confirmation: null
    },
    userSaved: false,
    sending: false
  }),
  methods: {
    saveUser () {
      this.sending = true
      this.$http.post('/api/users', this.form).then(response => {
        this.userSaved = true
        this.$store.dispatch('REGISTER', response.body)
        this.$router.push({name: 'home'})
      }, error => {
        // error callback
        this.sending = false
        this.errors = error.body.errors
      })
    },
  },
  created(){
    console.log(this.$store)
    if(this.$store.getters.currentUser){
      this.userSaved = true
    }
  }
}
</script>

<style lang="scss">
  #sign_up{
    .form{
      width: 300px;
      margin: 0 auto;
      padding: 10px
    }
  }
</style>
