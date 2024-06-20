<%-- 
[ 게시판 생성 ]
1. Spring 기반으로 MVC 패턴을 이용하여 게시판 생성
- 검색/등록/수정/삭제/페이징 처리 등... 
2. 게시판의 글 내용은 RDB(관계형데이터베이스) 연동하여 관리 (mysql,mariadb,orcle..)
3. WAS(Apache Tomcat)을 이용하여 웹 서비스 구동
[ 옵션 ]
4. 엑셀파일생성 : 저장된 게시글 목록을 Excel 파일로 저장
5. 파일업로드/다운로드 : 게시판 파일 첨부하여 저장 및 다운로드

start: ./gradlew bootRun
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.List" %>
<%@ page import="com.skycom.test.domain.Post" %>
<%
    int postsLength = (int)request.getAttribute("postsLength");
    int currentPage = 1;

    if(request.getParameter("page") != null) {
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch(Exception e) {
            currentPage = 1;
        }
    } 

    int pageLength = (int) Math.ceil(postsLength / 10.0);

    boolean firstPage = (currentPage == 1);
    boolean lastPage = (currentPage == pageLength);

    int firstBtn = 1; // 1         
    int endBtn = pageLength; // 1                  21
    int maxBtn = 6;

    if (currentPage > maxBtn/2) { // 1 3 false      1
        firstBtn = currentPage - (maxBtn/2);
    }
    if (firstBtn + maxBtn < pageLength) {
        endBtn = firstBtn + maxBtn;
    }
    if (endBtn == pageLength) {
        firstBtn = endBtn - maxBtn;
    }
    if (firstBtn < 1) {
        firstBtn = 1;
    }
    request.setAttribute("currentPage", currentPage);
    request.setAttribute("pageLength", pageLength);
    request.setAttribute("firstPage", firstPage);
    request.setAttribute("lastPage", lastPage);
    request.setAttribute("firstBtn", firstBtn);
    request.setAttribute("endBtn", endBtn);
%>
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="./styles/index.css"/>
    <title>test</title>
</head>
<body>
    <div class="board_box nowrap">
        <div>
            <div class="exelContainer nowrap mb_10px">
                <form id="uploadForm" class="nowrap" enctype="multipart/form-data">
                    <input id="uploadFileInput" type="file" name="file" accept=".xls, .xlsx"/>
                    <button id="uploadBtn" type="button" onclick="return uploadExel()">업로드</button>
                </form>
                <div>
                    <button id="downloadBtn" type="button" onclick="return downloadExel()">다운로드</button>
                </div>
            </div>
            <form class="selectForm nowrap mb_10px" id="searchForm" onsubmit="return postSearch()">
                <input type="text" id="id" name="id" placeholder="회원번호" value="${param.id}"/>
                <select name="gender">
                    <option value="">--성별--</option>
                    <option disabled>-------</option>
                    <c:forEach var="gender" items="${genders}">
                        <option value="${gender}" <c:if test="${param.gender == gender}">selected</c:if>>${gender}</option>
                    </c:forEach>
                </select>
                <input type="text" id="minAge" name="minAge" placeholder="최소 나이" value="${param.minAge}"/>
                <input type="text" id="maxAge" name="maxAge" placeholder="최대 나이" value="${param.maxAge}"/>
                <select name="location">
                    <option value="">--지역--</option>
                    <option disabled>-------</option>
                    <c:forEach var="location" items="${locations}">
                        <option value="${location}"  <c:if test="${param.location == location}">selected</c:if>>${location}</option>
                    </c:forEach>
                </select>
                <button class="selectBtn" type="submit">찾기</button>
            </form>
            <form class="insertContainer nowrap mb_10px" id="inputForm" onsubmit="return insertPost()">
                <input type="text" id="insertGender" name="insertGender" placeholder="성별"/>
                <input type="text" id="insertAge" name="insertAge" placeholder="나이"/>
                <input type="text" id="insertLocation" name="insertLocation" placeholder="주소"/>
                <button class="selectBtn" type="submit">등록</button>
            </form>
        </div>
        <div class="postContainer">
            <c:choose>
                <c:when test="${pageLength==0}">
                    <h1>조건에 맞는 데이터가 존재하지 않습니다.</h1>
                </c:when>
                <c:otherwise>
                    <table>
                        <tr class="postTitle">
                            <th>No</th>
                            <th>Id</th>
                            <th>Gender</th>
                            <th>Age</th>
                            <th>Location</th>
                            <th></th>
                        </tr>
                        <c:forEach var="post" items="${posts}" varStatus="status">
                            <tr id="postId_${post.id}" class="postRow">
                                <th>${(currentPage*10-10)+status.index+1}</th>
                                <td>${post.id}</td>
                                <td><input type="text" placeholder="${post.gender}" id="updateGender" value="${post.gender}"/></td>
                                <td><input type="text" placeholder="${post.age}" id="updateAge" value="${post.age}"/></td>
                                <td><input type="text" placeholder="${post.location}" id="updateLocation" value="${post.location}"/></td>
                                <td>
                                    <div class="nowrap">
                                        <button class="updateBtn" type="submit" onclick="return updatePost(${post.id})">수정</button>
                                        <button class="deleteBtn" type="submit" onclick="return deletePost(${post.id})">삭제</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </table>
                    <div class="pagingContainer">
                        <c:if test="${!(firstPage)}">
                            <div class="controlBtnContainer nowrap">
                                <c:if test="${!(firstBtn == 1)}">
                                    <button class="pagingBtn" onclick="movePage(1)">처음</button>
                                </c:if>
                                <button class="pagingBtn" onclick="movePage(${currentPage-1})">이전</button>
                            </div>
                        </c:if>
                        <div class="numberBtnContainer nowrap">
                            <c:forEach var="idx" begin="${firstBtn}" end="${endBtn}">
                                <c:choose>
                                    <c:when test="${currentPage == idx}">
                                        <button class="pagingBtn currentBtn">${idx}</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="pagingBtn" onclick="movePage(${idx})">${idx}</button>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                        <c:if test="${!(lastPage)}">
                            <div class="controlBtnContainer nowrap">
                                <button class="pagingBtn" onclick="movePage(${currentPage+1})">다음</button>
                                <c:if test="${!(endBtn == pageLength)}">
                                    <button class="pagingBtn" onclick="movePage(${pageLength})">끝</button>
                                </c:if>
                            </div>
                        </c:if>
                    </div>
                    <div>
                        <h3>${currentPage}/${pageLength}</h3>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    <script>
        function postSearch() {
            const id = document.getElementById('id').value;
            const minAge = document.getElementById('minAge').value;
            const maxAge = document.getElementById('maxAge').value;
            if (isNaN(id)) {
                alert("회원번호는 숫자만 입력 가능합니다.");
                return false;
            }
            if (isNaN(minAge) || isNaN(maxAge)) {
                alert("나이는 숫자만 입력 가능합니다.\nex) 20살 -> 20");
                return false;
            }
            if (parseInt(minAge) > parseInt(maxAge)) {
                alert("최소 나이 값이 최대 나이 값보다 높습니다.");
                return false;
            }
            return true;
        }

        function movePage(idx) {
            const params = new URLSearchParams(window.location.search);
            params.set('page', idx);
            window.location.href = '?'+params.toString()
        }
        
        function fetchPostDate(url, data) {
            fetch(url, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(data)
            })
            .then(response => {
                if (!(response.ok)) {
                    throw new Error(`${response.status} 에러 발생`)
                }
                return response.text();
            })
            .then(data => {
                alert(data);
                movePage(1);
            })
            .catch(error => {
                alert(error);
            })
        }

        function insertPost() {
            const gender = document.getElementById('insertGender').value;
            const age = document.getElementById('insertAge').value;
            const location = document.getElementById('insertLocation').value;
            if (!(gender && age && location)) {
                alert('값이 비어있습니다.');
                return false;
            }
            if (isNaN(age)) {
                alert("나이에는 숫자만 입력 가능합니다. \nex) 20살 -> 20");
                return false;
            }
            if (confirm('정말로 성별: '+gender+', 나이: '+age+', 주소: '+location+'(을)를 저장하시겠습니까?')) {
                const url = '/api/insert';
                const data = {
                    gender: gender,
                    age: age,
                    location: location
                };
                return fetchPostDate(url, data);
            } else {
                return false;
            }
        }
        
        function updatePost(postId) {
            if (confirm('정말로 Post id: '+postId+'를 수정하시겠습니까?')) {
                const gender = document.getElementById('postId_'+postId).querySelector('#updateGender').value;
                const age = document.getElementById('postId_'+postId).querySelector('#updateAge').value;
                const location = document.getElementById('postId_'+postId).querySelector('#updateLocation').value;
                if (isNaN(age)) {
                    alert("나이에는 숫자만 입력 가능합니다. \nex) 20살 -> 20");
                    return false;
                }
                const url = '/api/update';
                const data = {
                    id : postId,
                    gender : gender,
                    age : age,
                    location : location
                };
                return fetchPostDate(url, data);
            } else {
                return false;
            }
        }

        function deletePost(postId) {
            if (confirm('정말로 Post id: '+postId+'를 삭제하시겠습니까?')) {
                const url = '/api/delete';
                const data = {
                    id: postId
                };
                return fetchPostDate(url, data);
            } else {
                return false;
            }
        }
        
        function downloadExel() {
            const url = '/api/download';
            fetch(url, {
                method: 'GET',
                headers: {'Content-Type': 'application/json'}
            })
            .then(response => {
                if (response.ok) {
                    return response.blob();
                }
                throw new Error(`${response.status} 에러 발생`);
            })
            .then(blob => {
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.style.display = 'none';
                a.href = url;
                a.download = 'posts.xlsx';
                document.body.appendChild(a);
                a.click();
                window.URL.revokeObjectURL(url);
            })
            .catch(error => {
                alert(error);
            });
        }

        function uploadExel() {
            const uploadFormData = new FormData(document.getElementById('uploadForm'));
            const uploadFileInput = document.getElementById('uploadFileInput')
            const uploadFileName = uploadFileInput.files[0].name
            const uploadFileExtension = uploadFileName.split('.')[1];

            const url = '/api/upload';
            if (!(uploadFileExtension == 'xlsx' || uploadFileExtension == 'xls')) {
                alert("'"+uploadFileName+"'은 잘못된 파일 형식입니다.\n엑셀 형식의 파일만 업로드 가능합니다.\nex) .xlsx, .xls")
                return false;
            }
            fetch(url, {
                method: 'POST',
                body: uploadFormData
            })
            .then(response => {
                if (!(response.ok)) {
                    throw new Error(`${response.status} 에러 발생`)
                }
                return response.text();
            })
            .then(data => {
                alert(data);
                movePage(1);
            })
            .catch(error => {
                alert(error);
            })
        }
    </script>
</body>
</html>