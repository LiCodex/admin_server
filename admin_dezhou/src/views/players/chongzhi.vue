<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">

      <el-form-item label="会员ID">
        <el-input v-model="form.uid" type="text"></el-input>
      </el-form-item>

      <el-form-item label="充值数量">
        <el-input v-model="form.num" type="number"></el-input>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="onSubmit">确认充值</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { chongzhi } from '@/api/players'
  export default {
    data() {
      return {
        listLoading: true,
        form: {
          uid: '',
          num: ''
        }
      }
    },
    methods: {
      handleModifyStatus() {
        this.$message({
          message: '充值成功',
          type: 'success'
        })
      },
      onSubmit() {
        this.listLoading = true
        chongzhi(this.form).then(response => {
          this.handleModifyStatus()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      }
    }
  }
</script>
