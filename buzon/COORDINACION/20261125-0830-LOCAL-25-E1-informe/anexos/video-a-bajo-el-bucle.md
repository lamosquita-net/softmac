
#### CrGpuMain · bajo «ThreadControllerWithMessagePumpImpl::DoWork»: lento 2433 de 3656 ms, recuperado 1975 de 3796 ms (escalado ×0.96)

| lento | recuperado (escalado) | diferencia | función |
|---|---|---|---|
| 2132 | 1870 | +262 | gpu::Scheduler::RunNextTask |
| 172 | 14 | +158 | (propio) |
| 18 | 1 | +17 | base::subtle::TimeTicksNowIgnoringOverride |
| 16 | 1 | +15 | base::sequence_manager::internal::WorkQueue::RemoveCancelledTasks |
| 16 | 0 | +16 | gpu::CommandBufferStub::WaitForGetOffsetInRange |
| 6 | 8 | -2 | media::VideoToolboxFrameConverter::Convert |
| 13 | 0 | +13 | void partition_alloc::PartitionRoot::FreeInUnknownRoot< |
| 12 | 1 | +11 | base::sequence_manager::internal::WorkQueueSets::OnPopMinQueueInSet |
| 8 | 0 | +8 | base::sequence_manager::internal::TaskQueueImpl::NotifyWillProcessTask |
| 6 | 1 | +5 | non-virtual thunk to gpu::GpuWatchdogThread::DidProcessTask |
| 5 | 0 | +5 | tlv_get_addr |
| 4 | 0 | +4 | pthread_mutex_trylock |
| 4 | 0 | +4 | base::sequence_manager::internal::ThreadController::RunLevelTracker::OnWorkStarted |
| 4 | 0 | +4 | base::sequence_manager::internal::TaskQueueImpl::NotifyDidProcessTask |
| 3 | 0 | +3 | non-virtual thunk to gpu::GpuWatchdogThread::WillProcessTask |
| 2 | 1 | +1 | void partition_alloc::PartitionRoot::FreeInline< |
| 0 | 3 | -3 | viz::SkiaOutputDeviceBufferQueue::DoFinishSwapBuffers |
| 2 | 0 | +2 | gpu::ImageTransportSurfaceOverlayMacEGL::OnVSyncPresentation |
| 2 | 0 | +2 | _platform_bzero$VARIANT$Ivybridge |
| 2 | 0 | +2 | pthread_mutex_unlock |
| 2 | 0 | +2 | media::VideoToolboxFrameConverter::OnVideoFrameReleased |
| 2 | 0 | +2 | std::__Cr::__tree<std::__Cr::__value_type<base::sequence_manager::internal::TaskQueueImpl*, std::__Cr::unique_ptr<base::sequence_manager::in |
| 1 | 0 | +1 | 0x0e3bfcda |
| 1 | 0 | +1 | gpu::raster::GrCacheController::PurgeGrCache |
| 0 | 1 | -1 | ui::CVDisplayLinkMac::CVDisplayLinkCallbackOnCallbackThread |

#### CrGpuMain · bajo «gpu::Scheduler::RunNextTask»: lento 2132 de 3656 ms, recuperado 1942 de 3796 ms (escalado ×0.96)

| lento | recuperado (escalado) | diferencia | función |
|---|---|---|---|
| 1600 | 1539 | +61 | gpu::GpuChannel::ExecuteDeferredRequest |
| 145 | 259 | -114 | viz::SkiaOutputSurfaceImplOnGpu::SwapBuffers |
| 122 | 10 | +112 | (propio) |
| 29 | 22 | +7 | viz::SkiaOutputSurfaceImplOnGpu::FinishPaintRenderPass |
| 44 | 1 | +43 | base::sequence_manager::internal::TaskQueueImpl::TaskRunner::PostDelayedTask |
| 32 | 9 | +23 | gpu::SharedImageInterfaceInProcessBase::CreateSharedImageWithBufferOnGpuThread |
| 26 | 0 | +26 | void partition_alloc::PartitionRoot::FreeInUnknownRoot< |
| 19 | 0 | +19 | void std::__Cr::__stable_sort[abi:sqn240000]<std::__Cr::_ClassicAlgPolicy, bool  |
| 9 | 8 | +1 | gpu::SharedImageInterfaceInProcessBase::DestroySharedImageOnGpuThread |
| 14 | 0 | +14 | gpu::TaskGraph::Sequence::BeginTask |
| 12 | 2 | +10 | void partition_alloc::PartitionRoot::FreeInline< |
| 6 | 7 | -1 | viz::SkiaOutputSurfaceImplOnGpu::CreateSharedImage |
| 11 | 0 | +11 | base::subtle::TimeTicksNowIgnoringOverride |
| 8 | 1 | +7 | gpu::Scheduler::FindNextTaskFromRoot |
| 7 | 2 | +5 | gpu::SyncPointManager::EnsureFenceSyncReleased |
| 3 | 4 | -1 | viz::SkiaOutputSurfaceImplOnGpu::DestroySharedImage |
| 3 | 4 | -1 | _CFRelease |
| 6 | 0 | +6 | pthread_mutex_trylock |
| 6 | 0 | +6 | _pthread_mutex_firstfit_unlock_slow |
| 5 | 0 | +5 | _pthread_mutex_firstfit_lock_slow |
| 5 | 0 | +5 | pthread_mutex_unlock |
| 3 | 1 | +2 | viz::SkiaOutputSurfaceImplOnGpu::MakeCurrent |
| 3 | 1 | +2 | operator new |
| 3 | 1 | +2 | gpu::SyncPointOrderData::FinishProcessingOrderNumber |
| 3 | 0 | +3 | tlv_get_addr |

#### CrGpuMain · bajo «^__CFRunLoopRun$»: lento 2933 de 3656 ms, recuperado 2020 de 3796 ms (escalado ×0.96)

| lento | recuperado (escalado) | diferencia | función |
|---|---|---|---|
| 2580 | 1909 | +671 | __CFRunLoopDoSources0 |
| 155 | 13 | +142 | mach_port_insert_member |
| 92 | 6 | +86 | mach_port_extract_member |
| 18 | 5 | +13 | __CFRunLoopDoObservers |
| 19 | 3 | +16 | (propio) |
| 13 | 0 | +13 | void partition_alloc::PartitionRoot::FreeInline< |
| 8 | 0 | +8 | __CFRunLoopDoBlocks |
| 7 | 1 | +6 | __CFRunLoopServiceMachPort |
| 7 | 1 | +6 | _pthread_mutex_firstfit_lock_slow |
| 7 | 1 | +6 | malloc |
| 6 | 0 | +6 | free |
| 4 | 0 | +4 | _pthread_mutex_firstfit_unlock_slow |
| 4 | 0 | +4 | _dispatch_get_main_queue_port_4CF |
| 3 | 1 | +2 | mach_absolute_time |
| 0 | 3 | -3 | __CFRunLoopDoTimers |
| 2 | 0 | +2 | _pthread_mutex_unlock_init_slow |
| 2 | 0 | +2 | CFSetContainsValue |
| 0 | 2 | -2 | CFAbsoluteTimeGetCurrent |
| 1 | 0 | +1 | DYLD-STUB$$kdebug_trace |
| 1 | 0 | +1 | DYLD-STUB$$objc_msgSend |
| 1 | 0 | +1 | CFRunLoopGetMain |
| 1 | 0 | +1 | voucher_mach_msg_revert |
| 1 | 0 | +1 | _CFGetTSDCreateIfNeeded |
| 1 | 0 | +1 | pthread_mutex_unlock |
| 0 | 1 | -1 | __CFRunLoopModeIsEmpty |

#### Chrome_ChildIOThread · bajo «MojoTrap::TrapEventHandler»: lento 394 de 3656 ms, recuperado 61 de 3796 ms (escalado ×0.96)

| lento | recuperado (escalado) | diferencia | función |
|---|---|---|---|
| 162 | 19 | +143 | mojo::MessageDispatcher::Accept > mojo::InterfaceEndpointClient::HandleIncomingMessage |
| 136 | 20 | +116 | MojoDestroyMessageIpcz > ipcz::ParcelWrapper::~ParcelWrapper |
| 33 | 7 | +26 | (propio) |
| 9 | 0 | +9 | MojoDestroyMessageIpcz |
| 7 | 2 | +5 | mojo::SimpleWatcher::ArmOrNotify |
| 6 | 2 | +4 | mojo::MessageDispatcher::Accept > base::FeatureList::IsFeatureEnabled |
| 5 | 3 | +2 | mojo::core::ipcz_driver::MojoMessage::SetParcel > operator new[] |
| 6 | 0 | +6 | MojoDestroyMessageIpcz > base::allocator::dispatcher::internal::DispatcherImpl<base::PoissonAllocationSampler>::FreeFn |
| 6 | 0 | +6 | mojo::MessageDispatcher::Accept > mojo::MessageHeaderValidator::Accept |
| 4 | 1 | +3 | ipcz::Router::Get |
| 3 | 1 | +2 | mojo::MessageDispatcher::Accept |
| 2 | 2 | +0 | mojo::MessageDispatcher::Accept > non-virtual thunk to IPC::ChannelAssociatedGroupController::Accept |
| 3 | 0 | +3 | mojo::core::ipcz_driver::MojoMessage::SetParcel |
| 2 | 0 | +2 | mojo::MessageDispatcher::Accept > tlv_get_addr |
| 2 | 0 | +2 | ipcz::Router::Get > operator new |
| 2 | 0 | +2 | MojoDestroyMessageIpcz > void partition_alloc::PartitionRoot::FreeInUnknownRoot< |
| 2 | 0 | +2 | pthread_mutex_trylock |
| 2 | 0 | +2 | mojo::MessageDispatcher::Accept > base::Location::Current |
| 1 | 0 | +1 | mojo::core::ipcz_driver::MojoMessage::SetParcel > _platform_memmove$VARIANT$Nehalem |
| 1 | 0 | +1 | operator new > allocator_shim::internal::PartitionAllocFunctionsInternal< |
| 0 | 1 | -1 | pthread_self |
| 0 | 1 | -1 | MojoDestroyMessageIpcz > void partition_alloc::PartitionRoot::FreeInline< |

#### Chrome_ChildIOThread · bajo «MessagePumpKqueue::Run»: lento 657 de 3656 ms, recuperado 88 de 3796 ms (escalado ×0.96)

| lento | recuperado (escalado) | diferencia | función |
|---|---|---|---|
| 474 | 74 | +400 | non-virtual thunk to mojo::core:: |
| 80 | 5 | +75 | (propio) |
| 55 | 0 | +55 | gpu::mojom::GpuChannel_WaitForGetOffsetInRange_ProxyToResponder::Run |
| 14 | 1 | +13 | base::subtle::TimeTicksNowIgnoringOverride |
| 7 | 1 | +6 | base::sequence_manager::internal::ThreadController::RunLevelTracker::OnWorkStarted |
| 7 | 0 | +7 | void partition_alloc::PartitionRoot::FreeInline< |
| 4 | 3 | +1 |  |
| 4 | 0 | +4 | base::sequence_manager::internal::WorkQueue::RemoveCancelledTasks |
| 2 | 1 | +1 | tlv_get_addr |
| 2 | 0 | +2 | void partition_alloc::PartitionRoot::FreeInUnknownRoot< |
| 2 | 0 | +2 | pthread_mutex_trylock |
| 2 | 0 | +2 | base::sequence_manager::internal::ThreadController::RunLevelTracker::OnIdle |
| 2 | 0 | +2 | base::sequence_manager::internal::TaskQueueImpl::NotifyDidProcessTask |
| 1 | 0 | +1 | pthread_mutex_unlock |
| 1 | 0 | +1 | objc_autoreleasePoolPush |

#### Chrome_ChildIOThread · bajo «mojo::InterfaceEndpointClient::HandleIncomingMessage$»: lento 0 de 3656 ms, recuperado 0 de 3796 ms (escalado ×0.96)

| lento | recuperado (escalado) | diferencia | función |
|---|---|---|---|
