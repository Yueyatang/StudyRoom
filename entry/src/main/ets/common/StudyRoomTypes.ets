export interface TodoItem {
  id: number;
  text: string;
  completed: boolean;
  pinned: boolean;
}

export interface UserProfile {
  nickname: string;
  account: string;
  signature: string;
  targetTomatoes: number;
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
