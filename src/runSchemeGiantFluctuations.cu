// Filename: runSchemeGiantFluctuations.cu
//
// Copyright (c) 2010-2016, Florencio Balboa Usabiaga
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


bool runSchemeGiantFluctuations(){
  int threadsPerBlock = 512;
  if((ncells/threadsPerBlock) < 512) threadsPerBlock = 256;
  if((ncells/threadsPerBlock) < 256) threadsPerBlock = 128;
  if((ncells/threadsPerBlock) < 64) threadsPerBlock = 64;
  if((ncells/threadsPerBlock) < 64) threadsPerBlock = 32;
  int numBlocks = (ncells-1)/threadsPerBlock + 1;

  int nGhost = ncellst - ncells;
  int threadsPerBlockGhost = 512;
  if((nGhost/threadsPerBlockGhost) < 512) threadsPerBlockGhost = 256;
  if((nGhost/threadsPerBlockGhost) < 256) threadsPerBlockGhost = 128;
  if((nGhost/threadsPerBlockGhost) < 64) threadsPerBlockGhost = 64;
  if((nGhost/threadsPerBlockGhost) < 64) threadsPerBlockGhost = 32;
  int numBlocksGhost = (nGhost-1)/threadsPerBlockGhost + 1;

  //initialize random numbers
  size_t numberRandom = 18 * ncellst;
  if(!initializeRandomNumbersGPU(numberRandom,seed)) return 0;

  //Initialize textures cells
  if(!texturesCellsGhost()) return 0;
  
  //Inilialize ghost index
  if(!initGhostIndexGPU()) return 0;
  
  int substep;
  substep = 0;
  step = -numstepsRelaxation;

  while(step<numsteps){
    //Generate random numbers
    generateRandomNumbers(numberRandom);

    //Provide data to ghost cells
    kernelFeedGhostCellsGiantFluctuations<<<numBlocksGhost,threadsPerBlockGhost>>>
      (ghostToPIGPU,
       ghostToGhostGPU,
       densityGPU,
       densityPredictionGPU,
       vxGPU,
       vyGPU,
       vzGPU,
       vxPredictionGPU,
       vyPredictionGPU,
       vzPredictionGPU,
       cGPU,
       cPredictionGPU,
       dRand,
       substep);

    kernelFeedGhostCellsGiantFluctuations2<<<numBlocksGhost,threadsPerBlockGhost>>>
      (ghostToPIGPU,
       ghostToGhostGPU,
       densityGPU,
       densityPredictionGPU,
       vxGPU,
       vyGPU,
       vzGPU,
       vxPredictionGPU,
       vyPredictionGPU,
       vzPredictionGPU,
       cGPU,
       cPredictionGPU,
       dRand,
       substep);

    //First substep RK3
    kernelDpGiantFluctuations_1<<<numBlocks,threadsPerBlock>>>(densityGPU,
							       densityGPU,
							       vxGPU,
							       vyGPU,
							       vzGPU,
							       dmGPU,
							       dpxGPU,
							       dpyGPU,
							       dpzGPU,
							       cGPU,
							       cGPU,
							       dcGPU,
							       dRand,
							       ghostIndexGPU,
							       realIndexGPU,
							       substep,
							       0,1,-sqrt(3));

    kernelDpGiantFluctuations_2<<<numBlocks,threadsPerBlock>>>(densityPredictionGPU,
							       vxPredictionGPU,
							       vyPredictionGPU,
							       vzPredictionGPU,
							       dmGPU,
							       dpxGPU,
							       dpyGPU,
							       dpzGPU,
							       cPredictionGPU,
							       dcGPU,
							       ghostIndexGPU,
							       realIndexGPU);

    cutilSafeCall( cudaBindTexture(0,texVxGPU,vxPredictionGPU,ncellst*sizeof(double)));
    cutilSafeCall( cudaBindTexture(0,texVyGPU,vyPredictionGPU,ncellst*sizeof(double)));
    cutilSafeCall( cudaBindTexture(0,texVzGPU,vzPredictionGPU,ncellst*sizeof(double)));
    //Provide data to ghost cells
    kernelFeedGhostCellsGiantFluctuations<<<numBlocksGhost,threadsPerBlockGhost>>>
      (ghostToPIGPU,
       ghostToGhostGPU,
       densityGPU,
       densityPredictionGPU,
       vxGPU,
       vyGPU,
       vzGPU,
       vxPredictionGPU,
       vyPredictionGPU,
       vzPredictionGPU,
       cGPU,
       cPredictionGPU,
       dRand,substep);
    
    kernelFeedGhostCellsGiantFluctuations2<<<numBlocksGhost,threadsPerBlockGhost>>>
      (ghostToPIGPU,
       ghostToGhostGPU,
       densityGPU,
       densityPredictionGPU,
       vxGPU,
       vyGPU,
       vzGPU,
       vxPredictionGPU,
       vyPredictionGPU,
       vzPredictionGPU,
       cGPU,
       cPredictionGPU,
       dRand,
       substep);

    //Second substep RK3
    kernelDpGiantFluctuations_1<<<numBlocks,threadsPerBlock>>>(densityPredictionGPU,
							       densityGPU,
							       vxGPU,
							       vyGPU,
							       vzGPU,
							       dmGPU,
							       dpxGPU,
							       dpyGPU,
							       dpzGPU,
							       cPredictionGPU,
							       cGPU,
							       dcGPU,
							       dRand,
							       ghostIndexGPU,
							       realIndexGPU,
							       substep,
							       0.75,0.25,sqrt(3));

    kernelDpGiantFluctuations_2<<<numBlocks,threadsPerBlock>>>(densityPredictionGPU,
							       vxPredictionGPU,
							       vyPredictionGPU,
							       vzPredictionGPU,
							       dmGPU,
							       dpxGPU,
							       dpyGPU,
							       dpzGPU,
							       cPredictionGPU,
							       dcGPU,
							       ghostIndexGPU,
							       realIndexGPU);

    //Provide data to ghost cells
    kernelFeedGhostCellsGiantFluctuations<<<numBlocksGhost,threadsPerBlockGhost>>>
      (ghostToPIGPU,
       ghostToGhostGPU,
       densityGPU,
       densityPredictionGPU,
       vxGPU,
       vyGPU,
       vzGPU,
       vxPredictionGPU,
       vyPredictionGPU,
       vzPredictionGPU,
       cGPU,
       cPredictionGPU,
       dRand,
       substep);
    
    kernelFeedGhostCellsGiantFluctuations2<<<numBlocksGhost,threadsPerBlockGhost>>>
      (ghostToPIGPU,
       ghostToGhostGPU,
       densityGPU,
       densityPredictionGPU,
       vxGPU,
       vyGPU,
       vzGPU,
       vxPredictionGPU,
       vyPredictionGPU,
       vzPredictionGPU,
       cGPU,
       cPredictionGPU,
       dRand,
       substep);

    //Third substep RK3
    kernelDpGiantFluctuations_1<<<numBlocks,threadsPerBlock>>>(densityPredictionGPU,
							       densityGPU,
							       vxGPU,
							       vyGPU,
							       vzGPU,
							       dmGPU,
							       dpxGPU,
							       dpyGPU,
							       dpzGPU,
							       cPredictionGPU,
							       cGPU,
							       dcGPU,
							       dRand,
							       ghostIndexGPU,
							       realIndexGPU,
							       substep,
							       1./3.,2./3.,0);

    kernelDpGiantFluctuations_2<<<numBlocks,threadsPerBlock>>>(densityGPU,
							       vxGPU,
							       vyGPU,
							       vzGPU,
							       dmGPU,
							       dpxGPU,
							       dpyGPU,
							       dpzGPU,
							       cGPU,
							       dcGPU,
							       ghostIndexGPU,
							       realIndexGPU);

    cutilSafeCall( cudaBindTexture(0,texVxGPU,vxGPU,ncellst*sizeof(double)));
    cutilSafeCall( cudaBindTexture(0,texVyGPU,vyGPU,ncellst*sizeof(double)));
    cutilSafeCall( cudaBindTexture(0,texVzGPU,vzGPU,ncellst*sizeof(double)));
    
    
    step++;
    
    //cout << step << endl;
    
    if((!(step%samplefreq))&&(step>0)){
      //Provide data to ghost cells
      kernelFeedGhostCellsGiantFluctuations<<<numBlocksGhost,threadsPerBlockGhost>>>
	(ghostToPIGPU,
	 ghostToGhostGPU,
	 densityGPU,
	 densityPredictionGPU,
	 vxGPU,
	 vyGPU,
	 vzGPU,
	 vxPredictionGPU,
	 vyPredictionGPU,
	 vzPredictionGPU,
	 cGPU,
	 cPredictionGPU,
	 dRand,
	 substep);
      
      kernelFeedGhostCellsGiantFluctuations2<<<numBlocksGhost,threadsPerBlockGhost>>>
	(ghostToPIGPU,
	 ghostToGhostGPU,
	 densityGPU,
	 densityPredictionGPU,
	 vxGPU,
	 vyGPU,
	 vzGPU,
	 vxPredictionGPU,
	 vyPredictionGPU,
	 vzPredictionGPU,
	 cGPU,
	 cPredictionGPU,
	 dRand,
	 substep);

      cout << "STEP  " << step << endl;
      if(!gpuToHostBinaryMixture()) return 0;
      if(!saveFunctionsSchemeBinaryMixture(1)) return 0;
    }
    
  }
  
    

  freeRandomNumbersGPU();




  return 1;
}
