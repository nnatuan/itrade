<form name="frm_bot_client" id="frm_bot_client" method="post" action="<?php echo $link_page; ?>">
    <div class="right_col" role="main">
        <div class="">
            <div class="clearfix"></div>

            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="x_panel">
                        <div class="x_title">
                            <h2><?php echo $lbl_form_title; ?></h2>
                            <ul class="nav navbar-right panel_toolbox">
                                <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a></li>
                            </ul>
                            <div class="clearfix"></div>
                        </div>
                        <div class="x_content">
                            
                            <!-- VỊ TRÍ HỢP LÝ: ĐẶT CÙNG THANH CÔNG CỤ ĐẦU TRANG -->
                            <div class="top-filter qcare-top-filter clearfix" style="margin-bottom: 15px;">
                                <input name="btn_header_add" type="button" class="btn btn-primary" value="Cấp mới License cho Khách" 
                                    onclick="js_SetSubmitButtonClick(this.form, 'btn_add');" />	

                                <a href="<?php echo base_url('index.php/do_bot_client_listview/trash'); ?>" 
                                   class="btn btn-default pull-right" style="color: #c9302c; border-color: #d43f3a;">
                                    <i class="fa fa-trash"></i> Thùng rác / Tài khoản đã xóa
                                </a>
                            </div>
                            
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered jambo_table bulk_action">
                                    <thead>
                                        <tr>
                                             <th class="qcare-th-center qcare-th-stt">#</th>
                                             <th class="qcare-th-code">Số tài khoản MT5</th>
                                             <th>Họ và Tên Khách hàng</th>
                                             <th class="qcare-th-center">Mã bảo mật License Key</th>
                                             <th class="qcare-th-center">Số dư (Balance)</th>
                                             <th class="qcare-th-center qcare-th-date">Ngày hết hạn</th>
                                             <th class="qcare-th-center qcare-th-status">Trạng thái Bot</th>
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
                                                <input name="txtf_cmt5_account" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cmt5_account) ? $txtf_cmt5_account : ''; ?>" placeholder="Tìm Số TK MT5..." />					
                                            </td>
                                            <td>
                                                <input name="txtf_cfullname" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cfullname) ? $txtf_cfullname : ''; ?>" placeholder="Tìm tên khách..." />
                                            </td>
                                            <td></td>	
                                            <td></td>
                                            <td></td>
                                            <td>
                                                <select name="cbof_cbot_status" class="form-control input-sm" onchange="js_SetSubmitButtonClick(this.form, 'btn_filter');">
                                                    <option value="">-- Tất cả --</option>
                                                    <option value="1" <?php echo (isset($cbof_cbot_status) && $cbof_cbot_status == '1') ? 'selected' : ''; ?>>1: Khởi chạy</option>
                                                    <option value="0" <?php echo (isset($cbof_cbot_status) && $cbof_cbot_status == '0') ? 'selected' : ''; ?>>0: Tạm ngừng</option>
                                                </select>
                                            </td>
                                            <td></td>
                                        </tr> 
                                    
                                        <?php 
                                            if (isset($data_view) && is_array($data_view) && !empty($data_view)):
                                                $i = ($txt_current_page - 1) * $txt_row_per_page + 1; 
                                                foreach($data_view as $data):
                                                    $d_expiry = ($data['dlicense_expiry'] != '') ? date('d/m/Y', strtotime($data['dlicense_expiry'])) : '-';
                                                    $is_expired = strtotime($data['dlicense_expiry']) < time();
                                        ?>
                                          <tr class="even pointer">
                                             <td class="text-center"><?php echo $i; ?></td>
                                             <td><code style="color: #26b99a; font-size: 13px; font-weight: bold;"><?php echo $data['cmt5_account']; ?></code></td>
                                             <td class="text-left">
                                                <a href="<?php echo base_url() . 'index.php/do_bot_client/f_edit/' . $data['nid']; ?>" style="color: #337ab7; font-weight: bold;"><?php echo Fview_text($data['cfullname']); ?></a>
                                             </td>   
                                             <td class="text-center"><small class="text-muted"><?php echo $data['clicense_key']; ?></small></td>
                                             <td class="text-center" style="font-weight: bold; color: #1abb9c;">
                                                 $<?php echo number_format($data['fbalance'], 2); ?>
                                             </td>
                                             <td class="text-center">
                                                 <?php if($is_expired): ?>
                                                     <span class="label label-danger" style="font-size: 11px;"><?php echo $d_expiry; ?> (Hết hạn)</span>
                                                 <?php else: ?>
                                                     <span class="label label-success" style="font-size: 11px;"><?php echo $d_expiry; ?></span>
                                                 <?php endif; ?>
                                             </td>
                                             <td class="text-center">
                                                <a href="javascript:void(0)" onclick="update_status('tbot_client','<?php echo $data['nid']; ?>','cbot_status')">
                                                    <i id="i-cbot_status-<?php echo $data['nid']; ?>" class="i-status fa <?php if($data['cbot_status'] == 1) echo "fa-check text-success"; else echo "fa-times text-danger"; ?>" aria-hidden="true" style="font-size: 15px;"></i>
                                                </a>
                                             </td>
                                             <td class="text-center">
                                                <a href="<?php echo base_url() . 'index.php/do_bot_client/f_edit/' . $data['nid']; ?>" 
                                                   class="btn btn-warning btn-xs qcare-btn-action" title="Cấu hình tham số Input">
                                                   <i class="fa fa-edit"></i> Cấu hình
                                                </a>
                                                
                                                <a href="<?php echo base_url() . 'index.php/do_bot_client_listview/f_delete/' . $data['nid']; ?>" 
                                                   class="btn btn-danger btn-xs qcare-btn-action" title="Xóa tài khoản bản quyền" 
                                                   onclick="return confirm('Bạn có chắc muốn ẩn tài khoản bản quyền Bot này?');"><i class="fa fa-trash"></i></a>
                                            </td>
                                          </tr>
                                        <?php 
                                                $i++; 
                                                endforeach;
                                            else: 
                                        ?>
                                          <tr>
                                             <td colspan="8" class="text-center" style="font-style: italic; color: #73879C; padding: 20px;">
                                                <i class="fa fa-info-circle"></i> Không tìm thấy thông tin cấu hình Bot nào trùng khớp bộ lọc.
                                             </td>
                                          </tr>
                                        <?php endif; ?>
                                    </tbody>
                                </table>
                            </div>
                            
                            <table class="table qcare-table-pagination" cellspacing="1">
                                <tr>						
                                    <td></td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">	
                                            <label class="qcare-row-per-page-label"><?php echo $lbl_rows_per_page; ?>:</label>&nbsp;
                                            <input class="form-control text-center input-sm qcare-page-input" name="txt_row_per_page" type="text" size="5" value="<?php echo $txt_row_per_page; ?>" />&nbsp;
                                            <input name="btn_row_per_page" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>
                                    </td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">		
                                            <?php if($txt_current_page > 1): ?>
                                            <input class="btn btn-default btn-sm" name="btn_previous" type="button" value="<<" onclick="js_SetSubmitButtonClick(this.form, 'btn_previous');"/>&nbsp;	
                                            <?php endif; ?>
                                            
                                            <label class="qcare-page-indicator"><?php echo $txt_current_page . ' / ' . $txt_total_page; ?></label>&nbsp;
                                            
                                            <?php if($txt_current_page < $txt_total_page): ?>
                                            <input class="btn btn-default btn-sm" name="btn_next" type="button" value=">>" onclick="js_SetSubmitButtonClick(this.form, 'btn_next');"/>&nbsp;
                                            <?php endif ?>
                                                    
                                            <input class="form-control text-center input-sm qcare-page-input page-num" name="txt_current_page" type="text" value="<?php echo $txt_current_page; ?>" size="5" />&nbsp;
                                                   
                                            <input name="btn_page_number" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>	
                                    </td>
                                </tr>					
                            </table>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <input type="hidden" name="hidden_button" id="hidden_button"/>
    <input name="hidden_nid" type="hidden" value="0" />
    <input name="hidden_event" type="hidden" value="<?php echo $event; ?>" />
</form>