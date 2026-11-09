<form name="frm_staff_list" id="frm_staff_list" method="post" action="<?php echo $link_page; ?>">
    <div class="right_col" role="main">
        <div class="">
            <div class="clearfix"></div>
            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="x_panel">
                        <div class="x_title">
                            <h2><?php echo $lbl_form_title; ?></h2>
                            <div class="clearfix"></div>
                        </div>
                        <div class="x_content">
                            
                            <div class="top-filter qcare-top-filter">
                                <input name="btn_header_add" type="button" class="btn btn-primary" value="Thêm mới Tài khoản" 
                                    onclick="js_SetSubmitButtonClick(this.form,'btn_add');" />
                                <input type="hidden" name="hidden_button" id="hidden_button"/>	
                            </div>
                            
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered jambo_table bulk_action">
                                  <thead>
										<tr>
											 <th class="qcare-th-center qcare-th-stt">STT</th>
											 <th>ID đăng nhập</th>
											 <th>Họ và Tên</th>
											 <th>Email liên hệ</th>
											 <th class="qcare-th-center">Số điện thoại</th>
											 <th class="qcare-th-center" style="width: 140px;">Quyền hạn</th>
											 <th class="qcare-th-center" style="width: 110px;">Trạng thái</th>
											 <th class="qcare-th-center qcare-th-action">Thao tác</th>
										</tr>
									</thead>
                                  <tbody>
                                    <tr class="filter qcare-filter-row">
                                        <td class="text-center">
											<input name="btn_filter" type="button" class="btn btn-success btn-xs qcare-btn-filter-submit" value="Lọc" 
												onclick="js_SetSubmitButtonClick(this.form, this.name);" />
										</td>
                                        <td>
                                            <input name="txtf_cuserid" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cuserid) ? $txtf_cuserid : ''; ?>" placeholder="Tìm username..." />
                                        </td>
                                        <td>
                                            <input name="txtf_cfullname" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cfullname) ? $txtf_cfullname : ''; ?>" placeholder="Tìm tên..." />
                                        </td>
                                        <td>
                                            <input name="txtf_cemail" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cemail) ? $txtf_cemail : ''; ?>" placeholder="Tìm email..." />
                                        </td>
                                        <td>
                                            <input name="txtf_chandphone" type="text" class="form-control input-sm" value="<?php echo isset($txtf_chandphone) ? $txtf_chandphone : ''; ?>" placeholder="Tìm SĐT..." />
                                        </td>
                                        <td>
                                            <select name="cbof_crole" class="form-control input-sm" onchange="js_SetSubmitButtonClick(this.form, 'btn_filter');">
                                                <option value="">-- Tất cả --</option>
                                                <option value="sale" <?php echo (isset($cbof_crole) && $cbof_crole == 'sale') ? 'selected' : ''; ?>>Sale / Đại lý</option>
                                                <option value="admin" <?php echo (isset($cbof_crole) && $cbof_crole == 'admin') ? 'selected' : ''; ?>>Admin (Quản trị)</option>
                                            </select>
                                        </td>
                                        <td>&nbsp;</td>
                                        <td></td>
                                    </tr>
                                    
                                    <?php 
                                        if (isset($data_view) && is_array($data_view) && !empty($data_view)):
                                            $i = ($txt_current_page - 1) * $txt_row_per_page + 1; 
                                            foreach($data_view as $data):
                                    ?>
                                      <tr class="even pointer">
                                         <td class="text-center"><?php echo $i; ?></td>
                                         <td><strong><?php echo $data['cuserid']; ?></strong></td>
                                         <td class="text-left" style="color:#2a3f54; font-weight:bold;"><i class="fa fa-user"></i> <?php echo Fview_text($data['cfullname']); ?></td>
                                         <td><?php echo $data['cemail']; ?></td>
                                         <td class="text-center"><?php echo $data['chandphone']; ?></td>
                                         <td class="text-center">
                                            <?php 
                                                // ĐỒNG BỘ TẠI ĐÂY: Hiển thị nhãn vai trò tương ứng ngoài danh sách bảng
                                                if ($data['crole'] == 'admin') echo '<span class="label label-danger">Admin</span>';
                                                else echo '<span class="label label-success">Sale / Đại lý</span>';
                                            ?>
                                         </td>
                                         <td class="text-center">
                                            <?php 
                                                if ($data['cstatus'] == '1') echo '<span class="badge bg-green">Hoạt động</span>';
                                                else echo '<span class="badge bg-red">Khóa</span>';
                                            ?>
                                         </td>
                                         <td class="text-center">
											<a href="<?php echo base_url() . 'index.php/do_staff/f_edit/' . $data['nid']; ?>" class="btn btn-warning btn-xs qcare-btn-action"><i class="fa fa-edit"></i> Sửa</a>
											<a href="<?php echo base_url() . 'index.php/do_staff_listview/f_delete/' . $data['nid']; ?>" class="btn btn-danger btn-xs qcare-btn-action" onclick="return confirm('Bạn có chắc muốn xóa nhân viên này?');"><i class="fa fa-trash"></i></a>
										</td>
                                      </tr>
                                    <?php $i++; endforeach; else: ?>
                                      <tr><td colspan="8" class="text-center" style="font-style:italic; padding:20px;">Không có tài khoản nhân viên nào.</td></tr>
                                    <?php endif; ?>
                                  </tbody>
                                </table>
                            </div>
                            
                            <table class="table qcare-table-pagination" cellspacing="1">
								<tr><td></td><td class="qcare-pagination-block"><div class="form-inline pull-right"><label><?php echo $lbl_rows_per_page; ?>:</label>&nbsp;<input class="form-control text-center input-sm" name="txt_row_per_page" type="text" size="5" value="<?php echo $txt_row_per_page; ?>" />&nbsp;<input name="btn_row_per_page" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" /></div></td><td class="qcare-pagination-block"><div class="form-inline pull-right"><?php if($txt_current_page > 1): ?><input class="btn btn-default btn-sm" name="btn_previous" type="button" value="<<" onclick="js_SetSubmitButtonClick(this.form, 'btn_previous');"/>&nbsp;<?php endif; ?><label><?php echo $txt_current_page . ' / ' . $txt_total_page; ?></label>&nbsp;<?php if($txt_current_page < $txt_total_page): ?><input class="btn btn-default btn-sm" name="btn_next" type="button" value=">>" onclick="js_SetSubmitButtonClick(this.form, 'btn_next');"/>&nbsp;<?php endif ?><input class="form-control text-center input-sm" name="txt_current_page" type="text" value="<?php echo $txt_current_page; ?>" size="5" />&nbsp;<input name="btn_page_number" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" /></div></td></tr>					
							</table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <input name="hidden_nid" type="hidden" value="0" />
    <input name="hidden_event" type="hidden" value="<?php echo $event; ?>" />
</form>