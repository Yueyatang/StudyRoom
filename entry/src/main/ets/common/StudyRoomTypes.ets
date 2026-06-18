export interface TodoItem {
  id: number;
  text: string;
  completed: boolean;
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
