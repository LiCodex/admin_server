<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="80px">

      <el-form-item label="俱乐部 key">
        <el-input v-model="form.hallkey" type='number' placeholder="必须为数字"></el-input>
      </el-form-item>


      <el-form-item>
        <el-button type="primary" @click="onSubmit">立即删除</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { delclub } from '@/api/club'
  export default {
    data() {
      return {
        list: null,
        listLoading: true,
        form: {
          hallkey: null
        }
      }
    },
    methods: {
    	handleModifyStatus() {
        this.$message({
          message: '删除成功',
          type: 'success'
        })
      },
      onSubmit() {
        this.listLoading = true
        delclub(this.form).then(response => {
          var succ = response.data
          console.log("data:" + JSON.stringify(response))
          if (succ == 'success') {
            this.handleModifyStatus()
          }
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      }
    }
  }
</script>
