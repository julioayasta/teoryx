import type { CallableName, CallerContext } from './contracts.js';

export function canCall(functionName: CallableName, caller: CallerContext): boolean {
  if (caller.role === 'unauthorized') return false;

  switch (functionName) {
    case 'requestCoursePlanGeneration':
      return caller.role === 'school_planner' || caller.role === 'super_admin';
    case 'getCoursePlanStatus':
      return caller.role === 'school_planner' || caller.role === 'school_reviewer' || caller.role === 'school_publisher' || caller.role === 'super_admin' || caller.role === 'system';
    case 'publishCourseOffering':
      return caller.role === 'school_publisher' || caller.role === 'super_admin';
    case 'getLessonSpecificationsForCourse':
      return caller.role === 'student' || caller.role === 'school_planner' || caller.role === 'school_reviewer' || caller.role === 'school_publisher' || caller.role === 'super_admin';
    case 'requestLessonContent':
      return caller.role === 'student';
    case 'getContentGenerationStatus':
      return caller.role === 'student' || caller.role === 'school_planner' || caller.role === 'school_reviewer' || caller.role === 'school_publisher' || caller.role === 'super_admin' || caller.role === 'system';
    case 'requestSchoolLessonGeneration':
      return caller.role === 'school_planner' || caller.role === 'super_admin';
    case 'requestArtifactRegeneration':
      return caller.role === 'school_planner' || caller.role === 'super_admin' || caller.role === 'system';
    case 'approveArtifactForPublication':
      return caller.role === 'school_reviewer' || caller.role === 'super_admin';
    case 'publishValidatedArtifact':
      return caller.role === 'school_publisher' || caller.role === 'super_admin' || caller.role === 'system';
    case 'importCurriculumSource':
      return caller.role === 'super_admin';
    case 'requestPedagogicalAnalysis':
      return caller.role === 'super_admin' || caller.role === 'school_planner' || caller.role === 'school_reviewer' || caller.role === 'school_publisher';
    case 'getPedagogicalAnalysisStatus':
      return caller.role === 'super_admin' || caller.role === 'school_planner' || caller.role === 'school_reviewer' || caller.role === 'school_publisher' || caller.role === 'system';
  }
}

export function canAccessSchool(caller: CallerContext, schoolId: string): boolean {
  return caller.role === 'super_admin' || caller.role === 'system' || caller.schoolId === schoolId;
}
