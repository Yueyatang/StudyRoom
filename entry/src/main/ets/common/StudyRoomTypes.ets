export interface TodoItem {
  id: number;
  text: string;
  completed: boolean;
  pinned: boolean;
  estimatedTomatoes: number;
  doneTomatoes: number;
}

export interface UserProfile {
  nickname: string;
  account: string;
  signature: string;
  targetTomatoes: number;
}

export interface DailyTomatoRecord {
  date: string;
  count: number;
}

export interface CompanionProgress {
  level: number;
  totalAffinity: number;
  currentLevelAffinity: number;
  nextLevelAffinity: number;
}

export interface CompanionDailyTask {
  id: string;
  title: string;
  description: string;
  reward: number;
  progress: number;
  target: number;
  claimedCount: number;
}

export interface SceneData {
  name: string;
  bgColor: string;
  accentColor: string;
  atmosphere: string;
  quote: string;
  suggestion: string;
  musicLabel: string;
  soundLabel: string;
  imageName: string;
  musicName: string;
  soundName: string;
}

export type TimerMode = 'focus' | 'shortBreak' | 'longBreak';
export type AuthMode = 'login' | 'register';
