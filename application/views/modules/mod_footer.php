	<!-- footer content -->
        <footer>
          <div class="pull-right">
            HỆ THỐNG QUẢN TRỊ NỘI DUNG - CMS
          </div>
          <div class="clearfix"></div>
        </footer>
        <!-- /footer content -->
      </div>
    </div>

    <!-- jQuery -->
    <script src="<?php echo base_url(); ?>vendors/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap -->
    <script src="<?php echo base_url(); ?>vendors/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
    <!-- FastClick -->
    <script src="<?php echo base_url(); ?>vendors/fastclick/lib/fastclick.js"></script>
    <!-- NProgress -->
    <script src="<?php echo base_url(); ?>vendors/nprogress/nprogress.js"></script>
    <!-- Chart.js -->
    <script src="<?php echo base_url(); ?>vendors/Chart.js/dist/Chart.min.js"></script>
    <!-- gauge.js -->
    <script src="<?php echo base_url(); ?>vendors/gauge.js/dist/gauge.min.js"></script>
    <!-- bootstrap-progressbar -->
    <script src="<?php echo base_url(); ?>vendors/bootstrap-progressbar/bootstrap-progressbar.min.js"></script>
    <!-- iCheck -->
    <script src="<?php echo base_url(); ?>vendors/iCheck/icheck.min.js"></script>
    <!-- Skycons -->
    <script src="<?php echo base_url(); ?>vendors/skycons/skycons.js"></script>
    <!-- Flot -->
    <script src="<?php echo base_url(); ?>vendors/Flot/jquery.flot.js"></script>
    <script src="<?php echo base_url(); ?>vendors/Flot/jquery.flot.pie.js"></script>
    <script src="<?php echo base_url(); ?>vendors/Flot/jquery.flot.time.js"></script>
    <script src="<?php echo base_url(); ?>vendors/Flot/jquery.flot.stack.js"></script>
    <script src="<?php echo base_url(); ?>vendors/Flot/jquery.flot.resize.js"></script>
    <!-- Flot plugins -->
    <script src="<?php echo base_url(); ?>vendors/flot.orderbars/js/jquery.flot.orderBars.js"></script>
    <script src="<?php echo base_url(); ?>vendors/flot-spline/js/jquery.flot.spline.min.js"></script>
    <script src="<?php echo base_url(); ?>vendors/flot.curvedlines/curvedLines.js"></script>
    <!-- DateJS -->
    <script src="<?php echo base_url(); ?>vendors/DateJS/build/date.js"></script>
    <!-- JQVMap -->
    <script src="<?php echo base_url(); ?>vendors/jqvmap/dist/jquery.vmap.js"></script>
    <script src="<?php echo base_url(); ?>vendors/jqvmap/dist/maps/jquery.vmap.world.js"></script>
    <script src="<?php echo base_url(); ?>vendors/jqvmap/examples/js/jquery.vmap.sampledata.js"></script>
    <!-- bootstrap-daterangepicker -->
    <script src="<?php echo base_url(); ?>vendors/moment/min/moment.min.js"></script>
    <script src="<?php echo base_url(); ?>vendors/bootstrap-daterangepicker/daterangepicker.js"></script>

    <!-- Custom Theme Scripts -->
    <script src="<?php echo base_url(); ?>js/custom.min.js"></script>
		
	<script src="<?php echo base_url(); ?>js/js.js"></script>
	<script src="<?php echo base_url()?>js/simpleUpload.js" type="text/javascript"></script>
	<script src="<?php echo base_url()?>uploadify/jquery.uploadify.min.js" type="text/javascript"></script>

	<script>
	function update_status(_table,_id,_field) {
		$.ajax({
			type: "POST",
			url: "<?php echo base_url()?>index.php/ajax_actions/update_status",
			data: { table: _table, id: _id, field: _field },
			success: function(result) {
				//alert(result);
				tag = "#i-"+_field+"-"+_id;
				if(result==1) {
					$(tag).addClass("fa-check text-success");
					$(tag).removeClass("fa-times text-danger");
				} else {
					$(tag).addClass("fa-times text-danger");
					$(tag).removeClass("fa-check text-success");
				}
			}
		});
	}
	</script>
	
	<?php
	  // 1. Ép kiểu mảng chắc chắn sạch sẽ từ PHP
	  $arr_js_labels = array();
	  $arr_js_data = array();
	  
	  // Kiểm tra biến có tồn tại và đúng là mảng không bị lỗi truyền từ Controller
	  if (isset($arr_score_history) && is_array($arr_score_history) && !empty($arr_score_history)) {
		  foreach ($arr_score_history as $row_hist) {
			  $arr_js_labels[] = date('d/m', strtotime($row_hist['dtest_date']));
			  $arr_js_data[] = (int)$row_hist['noverall_score'];
		  }
	  } 
	  
	  // Bắt buộc phải có dữ liệu mờ (fallback) nếu mảng rỗng để Chart.js không bị crash
	  if (empty($arr_js_labels)) {
		  $arr_js_labels = array('Chưa đo');
		  $arr_js_data = array(0);
	  }

	  // Sử dụng array_values để ép index chạy từ 0, tránh ra định dạng JSON dạng {0:..., 1:...}
	  $json_labels = json_encode(array_values($arr_js_labels));
	  $json_data   = json_encode(array_values($arr_js_data));
	?>

	<script>
	document.addEventListener("DOMContentLoaded", function() {
		
		// Lấy dữ liệu điểm số hiện tại cho Doughnut Chart
		var currentScore = <?php echo isset($arr_latest_score['noverall_score']) ? (int)$arr_latest_score['noverall_score'] : 0; ?>;
		var remainScore = 100 - currentScore;

		// ========================================================
		// 1. KHỞI TẠO VÒNG TRÒN LONGEVITY SCORE (DOUGHNUT CHART)
		// ========================================================
		var canvasDoughnut = document.getElementById('scoreDoughnutChart');
		if (canvasDoughnut) {
			var ctxDoughnut = canvasDoughnut.getContext('2d');
			new Chart(ctxDoughnut, {
			  type: 'doughnut',
			  data: {
				labels: ['Điểm đạt', 'Còn lại'],
				datasets: [{
				  data: [currentScore, remainScore],
				  backgroundColor: ['#0f766e', '#e2e8f0'],
				  borderWidth: 0
				}]
			  },
			  options: {
				cutoutPercentage: 80,
				responsive: true,
				maintainAspectRatio: false,
				legend: { display: false },
				tooltips: { enabled: false }
			  }
			});
		}

		// ========================================================
		// 2. KHỞI TẠO BIỂU ĐỒ CỘT TIẾN TRÌNH (BAR CHART) - SỬA LỖI '0'
		// ========================================================
		var canvasBar = document.getElementById('progressBarChart');
		if (canvasBar) {
			var ctxBar = canvasBar.getContext('2d');
			new Chart(ctxBar, {
			  type: 'bar',
			  data: {
				// Nhận chuỗi JSON mảng chuẩn phẳng từ PHP
				labels: <?php echo $json_labels; ?>, 
				datasets: [{
				  label: 'Điểm',
				  data: <?php echo $json_data; ?>, 
				  backgroundColor: '#0f766e',
				  borderWidth: 1
				}]
			  },
			  options: {
				responsive: true,
				maintainAspectRatio: false,
				legend: { display: false },
				scales: {
				  xAxes: [{
					gridLines: { display: false },
					barPercentage: 0.5
				  }],
				  yAxes: [{
					ticks: {
					  beginAtZero: true,
					  max: 100
					}
				  }]
				}
			  }
			});
		}
	});
	</script>