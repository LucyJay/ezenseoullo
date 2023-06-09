package com.seoullo.tour.service;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.seoullo.tour.mapper.TourMapper;
import com.seoullo.tour.vo.ScheduleVO;
import com.seoullo.tour.vo.TourVO;
import com.seoullo.tour.vo.TourdateVO;
import com.seoullo.tour.vo.TourpointVO;

@Service
@Qualifier("TourServiceImpl")
public class TourServiceImpl implements TourService {

	@Autowired
	private TourMapper mapper;

	public static String uploadPath;

	@Override
	public List<TourVO> list(String tag, String title, String region) {
		// 해당 검색조건으로 투어 리스트를 가져온 후
		List<TourVO> list = mapper.list(tag, title, region);
		// 각 투어의 태그리스트를 세팅한다(리스트에서 태그가 보이기 때문)
		for (TourVO vo : list) {
			vo.setTagList(mapper.taglist(vo.getNo()));
		}
		return list;
	}

	@Override
	public List<TourVO> listByGuide(String id) {
		List<TourVO> list = mapper.listByGuide(id);
		for (TourVO vo : list) {
			vo.setTagList(mapper.taglist(vo.getNo()));
		}
		return list;
	}

	@Override
	public TourVO view(Long no, int inc) {
		TourVO vo = mapper.view(no);
		vo.setTourdateList(mapper.viewTourdate(no));
		vo.setScheduleList(mapper.viewSchedule(no));
		vo.setTourpointList(mapper.viewTourpoint(no));
		vo.setCheckpointList(mapper.viewCheckpoint(no));
		vo.setTagList(mapper.taglist(vo.getNo()));
		if (inc == 1) // inc값에 따라 조회수 증가 실행
			mapper.increaseHit(no);
		return vo;
	}

	@Override
	public Integer write(TourVO vo) {
		// tour 테이블에 insert하며 vo.no에 새로 추가된 투어번호 저장 
		mapper.write(vo);
		Long tourNo = vo.getNo();
		
		// tourdate 테이블에 insert
		for (TourdateVO tourdateVO : vo.getTourdateList()) {
			tourdateVO.setTourNo(tourNo);
			mapper.writeTourdate(tourdateVO);
		}
		
		// schedule 테이블에 insert
		for (ScheduleVO scheduleVO : vo.getScheduleList()) {
			scheduleVO.setTourNo(tourNo);
			mapper.writeSchedule(scheduleVO);
		}
		
		// tourpoint 테이블에 insert
		for (TourpointVO tourpointVO : vo.getTourpointList()) {
			tourpointVO.setTourNo(tourNo);
			mapper.writeTourpoint(tourpointVO);
		}
		
		// tag 테이블에 insert
		for (String tag : vo.getTagList()) {
			mapper.writeTag(tourNo, tag);
		}
		
		// checkpoint 테이블에 insert
		for (String checkpoint : vo.getCheckpointList()) {
			mapper.writeCheckpoint(tourNo, checkpoint);
		}
		
		return 1;
	}

	@Override
	public Integer update(TourVO vo, boolean changeImage, boolean changeSchedule, boolean changeTourpoint,
			boolean changeTag, boolean changeCheckpoint) {
		Long tourNo = vo.getNo();
		// tour 테이블 중 이미지가 아닌 값은 기본적으로 update함
		mapper.updateTour(vo);
		// tour 테이블 중 이미지 정보는 변경 시에만 update함
		if (changeImage)
			mapper.updateImage(vo);
		// schedule 테이블 변경 시 전체 delete 후 다시 insert
		if (changeSchedule) {
			mapper.deleteSchedule(tourNo);
			for (ScheduleVO scheduleVO : vo.getScheduleList()) {
				scheduleVO.setTourNo(tourNo);
				mapper.writeSchedule(scheduleVO);
			}
		}
		// tourpoint 테이블 변경 시 전체 delete 후 다시 insert
		if (changeTourpoint) {
			mapper.deleteTourpoint(tourNo);
			for (TourpointVO tourpointVO : vo.getTourpointList()) {
				tourpointVO.setTourNo(tourNo);
				mapper.writeTourpoint(tourpointVO);
			}
		}
		// tag 테이블 변경 시 전체 delete 후 다시 insert
		if (changeTag) {
			mapper.deleteTag(tourNo);
			for (String tag : vo.getTagList()) {
				mapper.writeTag(tourNo, tag);
			}
		}
		// checkpoint 테이블 변경 시 전체 delete 후 다시 insert
		if (changeCheckpoint) {
			mapper.deleteCheckpoint(tourNo);
			for (String checkpoint : vo.getCheckpointList()) {
				mapper.writeCheckpoint(tourNo, checkpoint);
			}
		}
		return null;
	}

	@Override
	public Integer close(Long no) {
		return mapper.close(no);
	}

	@Override
	public void tourNotNew() {
		mapper.tourNotNew();
	}

	@Override
	public void deleteTourFiles() {
		if (uploadPath != null) {
			List<String> dbList = new ArrayList<String>();
			dbList.addAll(mapper.tourDBFiles1()); // DB에 존재하는 파일을 모두 리스트화
			dbList.addAll(mapper.tourDBFiles2());
			dbList.addAll(mapper.tourDBFiles3());
			dbList.addAll(mapper.tourDBFiles4());
			List<Path> dbPathList = dbList.stream()
					.map(str -> Paths.get(uploadPath + str.substring(str.lastIndexOf("/") + 1, str.length())))
					.collect(Collectors.toList()); // Path의 List로 변경
			File systemDir = Paths.get(uploadPath).toFile(); // 파일 저장 폴더 
			// 실제 폴더 중 DB 파일 리스트에 없는 파일만 추출
			File[] deleteFiles = systemDir.listFiles(file -> dbPathList.contains(file.toPath()) == false);
			for (File f : deleteFiles)
				f.delete(); // DB에 없는 파일 삭제
		}
	}

}
