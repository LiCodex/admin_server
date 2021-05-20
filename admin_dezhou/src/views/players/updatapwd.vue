<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">

      <el-form-item label="旧密码">
        <el-input v-model="form.old_pwd" type='password' placeholder="请输入旧密码" ></el-input>
      </el-form-item>

      <el-form-item label="新密码">
        <el-input v-model="form.new_pwd" type='password' placeholder="请输入新密码" ></el-input>
      </el-form-item>

      <el-form-item label="新密码">
        <el-input v-model="form.confirm_pwd" type='password' placeholder="请再次输入新密码" ></el-input>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="onSubmit">修改密码</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { changepwd } from '@/api/players'
  export default {
    data() {
      return {
        listLoading: true,
        form: {
          old_pwd: '',
          new_pwd: '',
          confirm_pwd: '',
        }
      }
    },
    methods: {
      handleModifyStatus() {
        this.$message({
          message: '修改成功',
          type: 'success'
        })
      },
      onSubmit() {
        var string = {}
        for (var k in this.form) {
          if (this.form[k] != '') {
            string[k] = this.form[k]
          }
        }
        var obj = this.obj_contact(string)
        this.listLoading = true
        changepwd(obj).then(response => {
          this.handleModifyStatus()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      obj_contact(obj) {
        var s = ''
        for (var k in obj) {
          var v = obj[k]
          if (s == '') {
            s += k + '=' + v
          } else {
            s += '&' + k + '=' + v
          }
        }
        return s
      }
    }
  }
</script>
