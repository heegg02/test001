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
<% 
    int postsLength = ((List)request.getAttribute("posts")).size();
    int currentPage = 1;

    if(request.getParameter("page") != null) {
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch(Exception e) {
            currentPage = 1;
        }
    } 

    int end = currentPage * 10 - 1;
    int begin = end - 9;

    if(postsLength < end) {
        end = postsLength;
    }

    if (begin < 0) {
        begin = 0;
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
    request.setAttribute("begin", begin);
    request.setAttribute("end", end);
    request.setAttribute("pageLength", pageLength);
    request.setAttribute("firstPage", firstPage);
    request.setAttribute("lastPage", lastPage);
    request.setAttribute("firstBtn", firstBtn);
    request.setAttribute("endBtn", endBtn);

    System.out.println("currentPage " + currentPage);
    System.out.println("begin " + begin);
    System.out.println("end " + end);
    System.out.println("postsLength " + postsLength);
    System.out.println("pageLength " + pageLength);
    System.out.println("firstPage " + firstPage);
    System.out.println("lastPage " + lastPage);
    System.out.println("firstBtn " + firstBtn);
    System.out.println("endBtn " + endBtn);
    System.out.println("maxBtn " + maxBtn);
%>
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="./styles/index.css"/>
    <title>test</title>
</head>
<body>
    <div class="board_box">
        <h3 class="board_title">Board</h3>
        <div>
            <form id="searchForm" onsubmit="postSearch()">
                <select name="gender">
                    <option value="">성별</option>
                    <option disabled>-------</option>
                    <c:forEach var="gender" items="${genders}">
                        <option value="${gender}" <c:if test="${param.gender == gender}">selected</c:if>>${gender}</option>
                    </c:forEach>
                </select>
                <input type="text" id="minAge" name="minAge" placeholder="최소 나이" value="${param.minAge}"/>
                <input type="text" id="maxAge" name="maxAge" placeholder="최대 나이" value="${param.maxAge}"/>
                <select name="location">
                    <option value="">지역</option>
                    <option disabled>-------</option>
                    <c:forEach var="location" items="${locations}">
                        <option value="${location}"  <c:if test="${param.location == location}">selected</c:if>>${location}</option>
                    </c:forEach>
                </select>
                <button class="selectBtn" type="submit">찾기</button>
            </form>
        </div>
        <div>
            <form id="inputForm" onsubmit="">
                <input type="text" id="insertGender" name="insertGender" placeholder="성별"/>
                <input type="text" id="insertAge" name="insertAge" placeholder="나이"/>
                <input type="text" id="insertLocation" name="insertLocation" placeholder="주소"/>
                <button class="selectBtn" type="submit">등록</button>
            </form>
        </div>
        <c:choose>
            <c:when test="${pageLength==0}">
                <h1>조건에 맞는 데이터가 존재하지 않습니다.</h1>
            </c:when>
            <c:otherwise>
                <table>
                    <tr>
                        <th>No</th>
                        <th>Id</th>
                        <th>Gender</th>
                        <th>Age</th>
                        <th>Location</th>
                        <th></th>
                    </tr>
                    <c:forEach var="post" items="${posts}" begin="${begin}" end="${end}" varStatus="status">
                        <tr id="postId_${post.id}">
                            <td>${status.index+1}</td>
                            <td>${post.id}</td>
                            <td><input type="text" placeholder="${post.gender}" id="updateGender" value="${post.gender}"/></td>
                            <td><input type="text" placeholder="${post.age}" id="updateAge" value="${post.age}"/></td>
                            <td><input type="text" placeholder="${post.location}" id="updateLocation" value="${post.location}"/></td>
                            <td>
                               <button class="updateBtn" type="submit" onclick="updatePost(${post.id})">수정</button>
                               <button class="deleteBtn" type="submit" onclick="deletePost(${post.id})">삭제</button>
                            </td>
                        </tr>
                    </c:forEach>
                </table>
                <div>
                    <c:if test="${!(firstPage)}">
                        <c:if test="${!(firstBtn == 1)}">
                            <button class="paging_btn" onclick="pageingBtn(1)">처음</button>
                        </c:if>
                        <button class="paging_btn" onclick="pageingBtn(${currentPage-1})">이전</button>
                    </c:if>
                    <c:forEach var="idx" begin="${firstBtn}" end="${endBtn}">
                        <c:choose>
                            <c:when test="${currentPage == idx}">
                                <button class="paging_btn currentPage" onclick="pageingBtn(${idx})">${idx}</button>
                            </c:when>
                            <c:otherwise>
                                <button class="paging_btn" onclick="pageingBtn(${idx})">${idx}</button>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${!(lastPage)}">
                        <button class="paging_btn" onclick="pageingBtn(${currentPage+1})">다음</button>
                        <c:if test="${!(endBtn == pageLength)}">
                            <button class="paging_btn" onclick="pageingBtn(${pageLength})">끝</button>
                        </c:if>
                    </c:if>
                </div>
                <div>
                    <h3>${currentPage}/${pageLength}</h3>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <script>
        function postSearch() {
            const minAge = document.getElementById('minAge').value;
            const maxAge = document.getElementById('maxAge').value;
            if (minAge && maxAge) {
                if(minAge > maxAge) {
                    alert("최소 나이 값이 최대 나이 값보다 높습니다.");
                    return false;
                }
            }
            return true;
        }
        
        function pageingBtn(idx) {
            const params = new URLSearchParams(window.location.search);
            params.set('page', idx);
            window.location.href = '?'+params.toString()
        }
        
        function updatePost(postId) {
            if (confirm('정말로 Post id.'+postId+'를 수정하시겠습니까?')) {
                const gender = document.getElementById('postId_'+postId).querySelector('#updateGender').value;
                const age = document.getElementById('postId_'+postId).querySelector('#updateAge').value;
                const location = document.getElementById('postId_'+postId).querySelector('#updateLocation').value;
                const url = 'http://localhost:8080/update';
                console.log(url)

                fetch(url, {
                    method: 'PUT',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        id: postId,
                        gender: gender,
                        age: age,
                        location: location
                    })
                })

                alert("수정 성공");
                const params = new URLSearchParams(window.location.search);
                params.set('page', 1);
                // window.location.href = '?'+params.toString()
            }
        }

        function deletePost(postId) {
            if (confirm('정말로 Post id.'+postId+'를 삭제하시겠습니까?')) {
                const url = 'http://localhost:8080/delete?id='+postId;
                console.log(url)

                fetch(url, {
                    method: 'DELETE',
                    headers: {'Content-Type': 'application/json'}
                })

                alert("수정 성공");
                const params = new URLSearchParams(window.location.search);
                params.set('page', 1);
                window.location.href = '?'+params.toString()
            }
        }
    </script>
</body>
</html>