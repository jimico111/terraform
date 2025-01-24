#!/bin/bash

sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel

sudo systemctl enable --now httpd

cat << \EOF > /var/www/html/index.php
<?php
// 데이터베이스 연결 설정
$host = '${db_address}';
$username = '${db_username}';
$password = '${db_password}';
$dbname = 'fortune_cookies';

$conn = mysqli_connect($host, $username, $password, $dbname);

if (!$conn) {
  die("데이터베이스 연결 실패: " . mysqli_connect_error());
}

mysqli_set_charset($conn, "utf8");

// 포춘 쿠키 메시지 추가 처리
if (isset($_POST['add_fortune'])) {
  $new_fortune = trim($_POST['new_fortune']);
  $category = $_POST['category'];

  if (!empty($new_fortune)) {
    $add_query = "INSERT INTO fortunes (message, category) VALUES ('$new_fortune', '$category')";
    mysqli_query($conn, $add_query);
  }
}

// 포춘 쿠키 메시지 삭제 처리
if (isset($_POST['delete_fortune'])) {
  $fortune_id = $_POST['fortune_id'];
  $delete_query = "DELETE FROM fortunes WHERE id = $fortune_id";
  mysqli_query($conn, $delete_query);
}

// 랜덤 포춘 쿠키 메시지 선택
$random_fortune_query = "SELECT * FROM fortunes ORDER BY RAND() LIMIT 1";
$random_result = mysqli_query($conn, $random_fortune_query);
$random_fortune = mysqli_fetch_assoc($random_result);

// 전체 포춘 쿠키 메시지 목록 조회
$fortune_list_query = "SELECT * FROM fortunes ORDER BY category, message";
$fortune_list_result = mysqli_query($conn, $fortune_list_query);
?>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>행운의 포춘쿠키</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      background-color: #f0e6d2;
    }
    .fortune-cookie {
      background-color: #fff;
      border: 2px solid #d4af37;
      border-radius: 10px;
      padding: 20px;
      text-align: center;
      margin-bottom: 20px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background-color: #fff;
    }
    th, td {
      border: 1px solid #d4af37;
      padding: 8px;
      text-align: left;
    }
    button {
      background-color: #d4af37;
      color: #fff;
      border: none;
      padding: 10px 15px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <div class="fortune-cookie">
    <h1>🥠 행운의 포춘쿠키 🥠</h1>
    <?php if ($random_fortune): ?>
      <h2><?= htmlspecialchars($random_fortune['message']) ?></h2>
      <p>카테고리: <?= htmlspecialchars($random_fortune['category']) ?></p>
    <?php endif; ?>

    <form method="post">
      <button type="submit" name="random_fortune">새로운 운세 보기</button>
    </form>
  </div>

  <h2>새 운세 추가</h2>
  <form method="post">
    <input type="text" name="new_fortune" placeholder="새 운세 메시지" required>
    <select name="category">
      <option value="행운">행운</option>
      <option value="사랑">사랑</option>
      <option value="성공">성공</option>
      <option value="건강">건강</option>
      <option value="기타">기타</option>
    </select>
    <button type="submit" name="add_fortune">운세 추가</button>
  </form>

  <h2>운세 목록</h2>
  <table>
    <tr>
      <th>메시지</th>
      <th>카테고리</th>
      <th>삭제</th>
    </tr>
    <?php while ($fortune = mysqli_fetch_assoc($fortune_list_result)): ?>
      <tr>
        <td><?= htmlspecialchars($fortune['message']) ?></td>
        <td><?= htmlspecialchars($fortune['category']) ?></td>
        <td>
          <form method="post">
            <input type="hidden" name="fortune_id" value="<?= $fortune['id'] ?>">
            <button type="submit" name="delete_fortune">삭제</button>
          </form>
        </td>
      </tr>
    <?php endwhile; ?>
  </table>
</body>
</html>

<?php
// 데이터베이스 연결 종료
mysqli_close($conn);
?>
EOF
