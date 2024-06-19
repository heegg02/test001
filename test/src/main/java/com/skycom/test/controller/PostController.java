package com.skycom.test.controller;

import com.skycom.test.domain.Post;
import com.skycom.test.service.ExelService;
import com.skycom.test.service.PostService;

import java.util.List;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.RequestMapping;



@Controller
@RequestMapping("/")
public class PostController {

    @Autowired
    private PostService postService;

    @Autowired
    private ExelService exelService;

    @GetMapping("/")
    public String main(Model model,
                        @RequestParam(name="page", required=false, defaultValue="1") int page,
                        @RequestParam(name="gender", required=false, defaultValue="") String gender,
                        @RequestParam(name="minAge", required=false, defaultValue="0") int minAge,
                        @RequestParam(name="maxAge", required=false, defaultValue="0") int maxAge,
                        @RequestParam(name="location", required=false, defaultValue="") String location) {

        int postsLength = postService.postsLength(gender, minAge, maxAge, location);
        List<String> genders = postService.gendersTypeSelector();
        List<String> locations = postService.locationsTypeSelector();
        List<Post> posts = postService.postSelector(page, gender, minAge, maxAge, location);

        model.addAttribute("posts", posts);
        model.addAttribute("genders", genders);
        model.addAttribute("locations", locations);
        model.addAttribute("postsLength", postsLength);
        return "index";
    }
    
    @PostMapping("/api/insert")
    public ResponseEntity<String> insertPost(@RequestBody Post request) {
        postService.insertPost(request.getGender(), request.getAge(), request.getLocation());
        return ResponseEntity.ok("등록 성공");
    }
    

    @PostMapping("/api/update")
    public ResponseEntity<String> updatePost(@RequestBody Post request) {
        postService.updatePost(request.getId(), request.getGender(), request.getAge(), request.getLocation());
        return ResponseEntity.ok("수정 성공");    
    }

    @PostMapping("/api/delete")
    public ResponseEntity<String> deletePost(@RequestBody Post request) {
        postService.deletePost(request.getId());
        return ResponseEntity.ok("삭제 성공");    
    }

    @GetMapping("/api/download")
    public ResponseEntity<Resource> downloadPost() throws IOException {
        List<Post> posts = postService.downloadPost();
        
        return ResponseEntity.ok()
                            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=posts.xlsx")
                            .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                            .body(exelService.xlsxBuilder(posts));
    }

    @PostMapping("/api/upload")
    public ResponseEntity<String> postMethodName(@RequestParam(name="file") MultipartFile file) throws IOException {
        exelService.fileUpload(file);
        return ResponseEntity.ok("업로드 완료");
    }
}
