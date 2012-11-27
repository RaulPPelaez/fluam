// Filename: freeCellsGhostGPU.cu
//
// Copyright (c) 2010-2012, Florencio Balboa Usabiaga
//
// This file is part of Fluam
//
// Fluam is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Fluam is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Fluam. If not, see <http://www.gnu.org/licenses/>.


bool freeCellsGhostGPU(){
  cudaFree(densityGPU);
  cudaUnbindTexture(texVxGPU);
  cudaUnbindTexture(texVyGPU);
  cudaUnbindTexture(texVzGPU);    
  cudaFree(vxGPU);
  cudaFree(vyGPU);
  cudaFree(vzGPU);
  cudaFree(densityPredictionGPU);
  cudaFree(vxPredictionGPU);
  cudaFree(vyPredictionGPU);
  cudaFree(vzPredictionGPU);

  cudaFree(dmGPU);
  cudaFree(dpxGPU);
  cudaFree(dpyGPU);
  cudaFree(dpzGPU);

  cudaFree(rxcellGPU);
  cudaFree(rycellGPU);
  cudaFree(rzcellGPU);

  cudaFree(ghostIndexGPU);
  cudaFree(realIndexGPU);
  cudaFree(ghostToPIGPU);
  cudaFree(ghostToGhostGPU);

  cudaFree(stepGPU);

  cout << "FREE MEMORY GPU :               DONE" << endl; 


  return 1;
}
