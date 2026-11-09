function checkTitleSEO(title,name) {
	keyword = $('#ckeyword').val();
            let score = 0;

            // Lấy tiêu đề trang
			/*
            const title = document.querySelector('title');
            if (!title) {
                console.error('No title tag found on this page.');
                return 0;
            }			
            const titleText = title.textContent;
			*/
			titleText = title;
            // Kiểm tra độ dài tiêu đề
            if (titleText.length >= 10 && titleText.length <= 70) {
                score += 5; // Độ dài tiêu đề hợp lý
            } else if (titleText.length > 70) {
                score += 3; // Tiêu đề quá dài
            } else {
                score += 2; // Tiêu đề quá ngắn
            }

            // Kiểm tra sự hiện diện của từ khóa trong tiêu đề
            if (titleText.toLowerCase().includes(keyword.toLowerCase())) {
                score += 3; // Từ khóa có trong tiêu đề
            }

            // Kiểm tra sự rõ ràng và mô tả của tiêu đề
            if (titleText.split(' ').length > 1 && titleText.length >= 20) {
                score += 2; // Tiêu đề rõ ràng và mô tả tốt
            } else if (titleText.split(' ').length <= 1) {
                score += 1; // Tiêu đề quá ngắn
            }
			
			if(keyword!="") {
				$('#seo-score-'+name).html('SEO Score: <strong>' + score + ' / 10</strong>');
				$('#score-'+name).val(score);
			} else {
				$('#seo-score-'+name).html('SEO Score: N/A');
				$('#score-'+name).val(0);
			}
            //return score;
			
        }
		
function checkContentSEO(content,name) {
	keyword = $('#ckeyword').val();
            let score = 0;
            const keywordLower = keyword.toLowerCase();

            // Tiêu đề trang
            if (content.toLowerCase().includes(keywordLower)) {
                score += 2;
            }

            // Mô tả meta
            //const metaDescription = document.querySelector('meta[name="description"]');
            if (keyword.toLowerCase().includes(keywordLower)) {
                score += 2;
            }

            // Kiểm tra thẻ H1
            const h1 = document.querySelector('h1');
            if (h1 && h1.textContent.toLowerCase().includes(keywordLower)) {
                score += 2;
            }

            // Kiểm tra sự xuất hiện của từ khóa trong nội dung
            const bodyText = document.body.innerText.toLowerCase();
            const keywordCount = (bodyText.match(new RegExp(keywordLower, 'g')) || []).length;
            const wordCount = bodyText.split(/\s+/).length;
            const keywordDensity = (keywordCount / wordCount) * 100;

            if (keywordDensity >= 1 && keywordDensity <= 3) {
                score += 2;
            }

            // Kiểm tra liên kết nội bộ
            const internalLinks = document.querySelectorAll('a[href^="/"]');
            if (internalLinks.length > 0) {
                score += 2;
            }

			if(keyword!="") {
				$('#seo-score-'+name).html('SEO Score: <strong>' + score + ' / 10</strong>');
				//$('#score-'+name).val(score);
			} else {
				$('#seo-score-'+name).html('SEO Score: N/A');
				//$('#score-'+name).val(0);
			}
            //return score;
        }

/*		
function checkContentSEO(keyword) {
            let score = 0;
            const keywordLower = keyword.toLowerCase();

            // Tiêu đề trang
            const title = document.querySelector('title');
            if (title && title.textContent.toLowerCase().includes(keywordLower)) {
                score += 2;
            }

            // Mô tả meta
            const metaDescription = document.querySelector('meta[name="description"]');
            if (metaDescription && metaDescription.getAttribute('content').toLowerCase().includes(keywordLower)) {
                score += 2;
            }

            // Kiểm tra thẻ H1
            const h1 = document.querySelector('h1');
            if (h1 && h1.textContent.toLowerCase().includes(keywordLower)) {
                score += 2;
            }

            // Kiểm tra sự xuất hiện của từ khóa trong nội dung
            const bodyText = document.body.innerText.toLowerCase();
            const keywordCount = (bodyText.match(new RegExp(keywordLower, 'g')) || []).length;
            const wordCount = bodyText.split(/\s+/).length;
            const keywordDensity = (keywordCount / wordCount) * 100;

            if (keywordDensity >= 1 && keywordDensity <= 3) {
                score += 2;
            }

            // Kiểm tra liên kết nội bộ
            const internalLinks = document.querySelectorAll('a[href^="/"]');
            if (internalLinks.length > 0) {
                score += 2;
            }

            return score;
        }
		*/