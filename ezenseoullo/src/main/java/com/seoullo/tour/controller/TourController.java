package com.seoullo.tour.controller;

import java.io.File;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.multipart.MultipartFile;

import com.seoullo.member.vo.MemberVO;
import com.seoullo.tour.service.TourService;
import com.seoullo.tour.service.TourServiceImpl;
import com.seoullo.tour.vo.ScheduleVO;
import com.seoullo.tour.vo.TourVO;
import com.seoullo.tour.vo.TourdateVO;
import com.seoullo.tour.vo.TourpointVO;
import com.webjjang.util.file.FileUtil;

@Controller
@RequestMapping("/tour")
public class TourController {

	String path = "/upload/tour";

	@Autowired
	@Qualifier("TourServiceImpl")
	private TourService service;

	// 투어 리스트
	@RequestMapping("/list.do")
	public String list(String searchKey, String searchWord, String region, HttpSession session, Model model) {
		MemberVO loginVO = (MemberVO) session.getAttribute("login");

		if (loginVO != null) {
			Integer grade = loginVO.getGradeNo();
			
			// 가이드 등급일 경우 가이드 본인의 리스트로 이동
			if (grade != null && (grade == 2 || grade == 3)) {
				String id = loginVO.getId();
				model.addAttribute("list", service.listByGuide(id));
				return "tour/listByGuide";
			}
		}
		// 가이드 등급이 아닐 경우 일반적인 전체 리스트로 이동  + region에 지역 조건 넣음
		// 검색 기능: searchKey에 태그인지 제목인지 정하고, searchWord에 검색할 단어 입력
		if (searchWord != null && searchWord != "") {
			if (searchKey.equals("title")) // 제목 검색
				model.addAttribute("list", service.list(null, searchWord, region));
			else if (searchKey.equals("tag")) // 태그 검색
				model.addAttribute("list", service.list(searchWord, null, region));
			else // 검색어 없음
				model.addAttribute("list", service.list(null, null, region));
		} else
			model.addAttribute("list", service.list(null, null, region));
		return "tour/list";
	}

	// 상세보기
	@RequestMapping("/view.do")
	public String view(Long no, Model model) {
		model.addAttribute("tourvo", service.view(no, 1));
		return "tour/view";
	}

	// 미리보기
	@RequestMapping("/preview.do")
	public String preview(HttpSession session, Model model) throws Exception {
		// RestController에서 세션에 저장한 vo를 model에 add
		model.addAttribute("tourvo", session.getAttribute("vo"));
		session.removeAttribute("vo");
		return "tour/preview";
	}

	// 투어 등록 폼 화면
	@GetMapping("/write.do")
	public String write(Model model) {
		return "tour/write";
	}

	// 투어 등록 기능: 모든 입력폼의 정보를 받되 한 name이 여러 개 있을 수 있는 경우 배열로 받음
	@PostMapping("/write.do")
	public String write(MultipartFile thumbnailFile, MultipartFile mainImgFile, MultipartFile subImgFile, TourVO vo,
			String[] day, Integer[] maxNum, Integer[] priceA, Integer[] priceB, Integer[] dayNum, Integer[] starthour,
			Integer[] startminute, String[] schedule, String[] schDescription, MultipartFile[] pointImageFile,
			String[] pointTitle, String[] pointContent, String tags, String[] checkpoint, HttpServletRequest request,
			Model model) throws Exception {
		try {
			// thumbnail, mainImg, subImg 저장 처리
			vo.setThumbnail(upload(path, thumbnailFile, request));
			vo.setMainImg(upload(path, mainImgFile, request));
			vo.setSubImg(upload(path, subImgFile, request));

			// vo에 예약가능일 List 세팅 - 예약가능일 배열의 길이만큼 for문
			List<TourdateVO> tourdateList = new ArrayList<TourdateVO>();
			DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			for (int i = 0; i < day.length; i++) {
				TourdateVO tourdateVO = new TourdateVO();
				tourdateVO.setDay(sdf.parse(day[i]));
				tourdateVO.setMaxNum(maxNum[i]);
				tourdateVO.setPriceA(priceA[i]);
				tourdateVO.setPriceB(priceB[i]);
				tourdateList.add(tourdateVO);
			}
			vo.setTourdateList(tourdateList);

			// vo에 일정 List 세팅
			List<ScheduleVO> scheduleList = new ArrayList<ScheduleVO>();

			// 며칠까지 있는지: 타입에서 가져옴
			int maxDay = 1;
			if (!vo.getType().equals("당일")) {
				maxDay = vo.getType().charAt(2) - 48;
			}
			// maxDay만큼 for문 돌림
			for (int i = 1; i <= maxDay; i++) {
				int scheduleNum = 0;
				// dayNum이 해당 일차일 때마다 add
				for (int j = 0; j < dayNum.length; j++) {
					if (dayNum[j] == i) {
						ScheduleVO scheduleVO = new ScheduleVO();
						scheduleVO.setDayNum(dayNum[j]); //일차
						scheduleVO.setScheduleNum(++scheduleNum); //일차별 순서
						scheduleVO.setStarthour(starthour[j]);
						scheduleVO.setStartminute(startminute[j]);
						scheduleVO.setSchedule(schedule[j]);
						scheduleVO.setDescription(schDescription[j]);
						scheduleList.add(scheduleVO);
					}
				}
			}
			vo.setScheduleList(scheduleList);

			// vo에 투어포인트 List 세팅 - 배열의 길이만큼 for문
			List<TourpointVO> tourpointList = new ArrayList<TourpointVO>();
			for (int i = 0; i < pointTitle.length; i++) {
				TourpointVO tourpointVO = new TourpointVO();
				tourpointVO.setImage(upload(path, pointImageFile[i], request));
				tourpointVO.setTitle(pointTitle[i]);
				tourpointVO.setContent(pointContent[i]);
				tourpointList.add(tourpointVO);
			}
			vo.setTourpointList(tourpointList);

			// vo에 태그 List 세팅 : 하나의 String을 반점으로 split
			List<String> tagList = Arrays.asList(tags.split(","));
			Collections.reverse(tagList);
			vo.setTagList(tagList);

			// vo에 예약 시 주의사항 List 세팅 : 배열의 길이만큼 for문 
			List<String> checkpointList = new ArrayList<String>();
			for (int i = 0; i < checkpoint.length; i++) {
				checkpointList.add(checkpoint[i]);
			}
			vo.setCheckpointList(checkpointList);

			// DB 등록 처리
			service.write(vo);
		} catch (ParseException e) {
			System.out.println("parse 안됨");
		}
		return "redirect:/tour/list.do";
	}

	// 수정폼
	@GetMapping("/update.do")
	public String updateForm(Long no, HttpSession session, Model model) {
		// 기존 정보는 view 서비스로 가져온다
		TourVO vo = service.view(no, 0);
		MemberVO login = (MemberVO) session.getAttribute("login");
		// 해당 투어의 가이드인지 확인
		if (vo.getGuideId().equals(login.getId())) {

			// 태그리스트 -> String으로 변환하여 model에 저장
			String tags = "";
			for (String tag : vo.getTagList()) {
				tags += tag;
				tags += ",";
			}
			model.addAttribute("tags", tags.substring(0, tags.lastIndexOf(",")));

			// tourdate의 day 형식 -> String으로 jsp에 넣어야 하므로 status에 저장(수정에서 안 쓰이는 필드 활용)
			DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
			for (TourdateVO dateVO : vo.getTourdateList()) {
				dateVO.setStatus(sdf.format(dateVO.getDay()));
			}

			// 일정리스트 형식 - 일차별로 forEach를 돌리기 위해 일차별 List의 List로 변환
			List<List<ScheduleVO>> scList = new ArrayList<List<ScheduleVO>>();
			if (vo.getType().equals("당일"))
				scList.add(new ArrayList<ScheduleVO>()); // 당일은 하나만
			else {
				for (int i = 0; i < vo.getType().charAt(2) - 48; i++) {
					scList.add(new ArrayList<ScheduleVO>()); // 1박2일 이상은 여러 개
				}
			}

			int dayn = 1; // 일차
			for (List<ScheduleVO> scpdList : scList) {
				for (ScheduleVO svo : vo.getScheduleList()) {
					if (svo.getDayNum() == dayn) // DB에서 가져온 일정을 각 일차별로 리스트에 나누어 저장
						scpdList.add(svo);
				}
				dayn++;
			}
			model.addAttribute("scList", scList);

			model.addAttribute("tourvo", vo);
			return "tour/update";
		} // 해당 투어의 가이드가 아닌 경우 수정 페이지로 접근할 수 없으며 리스트로 돌아간다.
		return "redirect:/tour/list.do";
	}

	// 투어 수정 기능
	@PostMapping("/update.do")
	public String update(MultipartFile thumbnailFile, MultipartFile mainImgFile, MultipartFile subImgFile, TourVO vo,
			Integer[] dayNum, Integer[] starthour, Integer[] startminute, String[] schedule, String[] schDescription,
			MultipartFile[] pointImageFile, String[] pointTitle, String[] pointContent, String tags,
			String[] checkpoint, HttpServletRequest request, Model model) throws Exception {
		try {
			Long no = vo.getNo();
			// 기존 데이터 불러오기(비교용)
			TourVO oldVO = service.view(no, 0);

			boolean changeImage = false; // DB에서 썸네일, 메인이미지, 서브이미지를 변경할지 여부 : 하나라도 변경하면 true
			
			// thumbnail, mainImg, subImg 저장 처리 (입력했으면 저장)
			if (thumbnailFile != null && !thumbnailFile.getOriginalFilename().equals("")) {
				vo.setThumbnail(upload(path, thumbnailFile, request));
				changeImage = true;
			} else // 입력하지 않았으면 기존 데이터로 세팅 (다른 이미지 때문에 changeImage가 true일 수 있으므로)
				vo.setThumbnail(oldVO.getThumbnail());
			if (mainImgFile != null && !mainImgFile.getOriginalFilename().equals("")) {
				vo.setMainImg(upload(path, mainImgFile, request));
				changeImage = true;
			} else
				vo.setMainImg(oldVO.getMainImg());
			if (subImgFile != null && !subImgFile.getOriginalFilename().equals("")) {
				vo.setSubImg(upload(path, subImgFile, request));
				changeImage = true;
			} else
				vo.setSubImg(oldVO.getSubImg());

			// scheduleList 세팅
			List<ScheduleVO> scheduleList = new ArrayList<ScheduleVO>();

			// 며칠까지 있는지: 타입에서 가져옴
			int maxDay = 1; // 당일일 경우 1
			if (!vo.getType().equals("당일")) {
				maxDay = vo.getType().charAt(2) - 48; // 당일이 아닐 경우 종류의 3번째 글자(1박2일 -> 2)
			}
			// 1부터 maxDay까지 for문 돌림
			for (int i = 1; i <= maxDay; i++) {
				int scheduleNum = 0; // 일차별 스케줄의 순서번호
				for (int j = 0; j < dayNum.length; j++) {
					if (dayNum[j] == i) {
						ScheduleVO scheduleVO = new ScheduleVO();
						scheduleVO.setDayNum(dayNum[j]); // 일차
						scheduleVO.setScheduleNum(++scheduleNum); // 순서번호
						if (starthour[j] != null && !((starthour[j]+"").equals("")))
							scheduleVO.setStarthour(starthour[j]); // 시작시
						if (startminute[j] != null && !((startminute[j]+"").equals("")))
							scheduleVO.setStartminute(startminute[j]); // 시작분
						scheduleVO.setSchedule(schedule[j]); // 일정
						if (schDescription[j] != null && !schDescription[j].equals(""))
							scheduleVO.setDescription(schDescription[j]); // 설명
						scheduleList.add(scheduleVO);
					}
				}
			}
			vo.setScheduleList(scheduleList);
			// 폼으로 들어온 일정 리스트와 기존 일정 리스트를 비교하여 다를 경우 changeSchedule가 true가 됨
			boolean changeSchedule = !vo.getScheduleList().toString().equals(oldVO.getScheduleList().toString());

			// tourpointList 세팅
			boolean changeTourpoint = false; //tourpoint 변경여부를 저장하는 변수
			List<TourpointVO> tourpointList = new ArrayList<TourpointVO>();
			
			for (int i = 0; i < pointTitle.length; i++) {
				if (pointImageFile[i] == null || pointImageFile[i].getOriginalFilename().equals("")) {
					changeTourpoint = false; // 투어포인트 이미지가 하나라도 비었을 경우 투어포인트는 DB에서 변경하지 않음
					break;
				}
				TourpointVO tourpointVO = new TourpointVO();
				tourpointVO.setImage(upload(path, pointImageFile[i], request));
				tourpointVO.setTitle(pointTitle[i]);
				tourpointVO.setContent(pointContent[i]);
				tourpointList.add(tourpointVO);
				changeTourpoint = true;
			}
			vo.setTourpointList(tourpointList);

			// tagList 세팅 : String을 반점 기준으로 split
			List<String> tagList = Arrays.asList(tags.split(","));
			
			// 폼으로 들어온 태그 리스트와 기존 태그 리스트를 비교하여 다를 경우 changeTag가 true가 됨
			boolean changeTag = !(tagList.toString().equals(oldVO.getTagList().toString()));
			Collections.reverse(tagList);
			vo.setTagList(tagList);

			// checkpointList 세팅
			List<String> checkpointList = new ArrayList<String>();
			for (int i = 0; i < checkpoint.length; i++) {
				checkpointList.add(checkpoint[i]);
			}
			vo.setCheckpointList(checkpointList);
			
			// 폼으로 들어온 checkpoint 리스트와 기존 checkpoint 리스트를 비교하여 다를 경우 changeCheckpoint가 true가 됨
			boolean changeCheckpoint = !(vo.getCheckpointList().toString()
					.equals(oldVO.getCheckpointList().toString()));
			
			// vo와 함께 각 테이블의 변경 여부를 매개변수로 보냄
			service.update(vo, changeImage, changeSchedule, changeTourpoint, changeTag, changeCheckpoint);
		} catch (ParseException e) {
			System.out.println("parse 안됨");
		}
		return "redirect:/tour/list.do";
	}

	// 모집종료 메서드
	@RequestMapping("/close.do")
	public String close(Long no) {
		service.close(no);
		return "redirect:/tour/list.do";
	}

	// 투어 등록용 파일 업로드 메서드 - fileUtil.jar를 활용한 static 메서드
	public static String upload(final String PATH, MultipartFile multiFile, HttpServletRequest request)
			throws Exception {
		String fileFullName = ""; // 저장 경로를 포함한 파일명을 담을 변수
		if (multiFile != null && !multiFile.getOriginalFilename().equals("")) {
			String fileName = multiFile.getOriginalFilename(); // 경로 제외 파일명
			String uploadPath = FileUtil.getRealPath(PATH, fileName, request); // 저장 경로를 포함한 파일명
			
			// TourServiceImpl.uploadPath: static 변수 -> 파일 자동 삭제 서비스에서 파일 위치를 찾을 때 사용하기 위해 이미지 최초 등록 시 위치를 변수에 저장해 줌
			if(TourServiceImpl.uploadPath == null) {
				TourServiceImpl.uploadPath = uploadPath.substring(0, uploadPath.lastIndexOf("\\")+1);
				// 이미지 저장 최초 실행 시 콘솔에도 파일 저장 위치를 띄움
				System.out.println("uploadPath: " + TourServiceImpl.uploadPath);
			}
			
			File saveFile = FileUtil.noDuplicate(uploadPath); // 파일명 중복 시 숫자를 붙임
			fileFullName = PATH + "/" + saveFile.getName(); // 실제 저장될 경로 포함 파일명
			multiFile.transferTo(saveFile); // 파일 저장
		} else {
			fileFullName = PATH + "/" + "noImage.jpg"; // multiFile 변수에 값이 없을 경우
		}
		return fileFullName;
	}
}
