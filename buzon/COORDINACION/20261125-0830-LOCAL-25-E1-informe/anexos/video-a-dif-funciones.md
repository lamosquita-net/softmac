
## CrGpuMain: lento 3245/3656 activas (89 %), recuperado 2046/3796 (54 %)

### inclusivas: más en el tramo lento (muestras de 1 ms; recuperado escalado a la misma duración)

|  3245 |    1971 |  +1274 | base::sequence_manager::internal::ThreadControllerWithMessagePumpImpl::Run |
|  3245 |    1971 |  +1274 | base::MessagePumpCFRunLoopBase::Run |
|  3245 |    1971 |  +1274 | content::GpuMain |
|  3245 |    1971 |  +1274 | content::ContentMainRunnerImpl::Run |
|  3245 |    1971 |  +1274 | start |
|  3245 |    1971 |  +1274 | content::ContentMain |
|  3245 |    1971 |  +1274 | base::MessagePumpNSRunLoop::DoRun |
|  3245 |    1971 |  +1274 | base::RunLoop::Run |
|  3245 |    1971 |  +1274 | ChromeMain |
|  3245 |    1971 |  +1274 | main |
|  3202 |    1967 |  +1235 | -[NSRunLoop(NSRunLoop) runMode:beforeDate:] |
|  3114 |    1958 |  +1156 | CFRunLoopRunSpecific |
|  2933 |    1946 |   +987 | __CFRunLoopRun |
|  2580 |    1909 |   +671 | __CFRunLoopDoSources0 |
|  2518 |    1906 |   +612 | __CFRunLoopDoSource0 |
|  2502 |    1906 |   +596 | base::MessagePumpCFRunLoopBase::RunWorkSource |
|  2502 |    1906 |   +596 | __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ |
|  2508 |    1913 |   +595 | base::apple::CallWithEHFrame |
|  2496 |    1906 |   +590 | invocation function for block in base::MessagePumpCFRunLoopBase::RunWorkSource |
|  2433 |    1902 |   +531 | non-virtual thunk to base::sequence_manager::internal::ThreadControllerWithMessagePumpImpl::DoWork |
|  2132 |    1870 |   +262 | gpu::Scheduler::RunNextTask |
|  1717 |    1558 |   +159 | <deduplicated_symbol> |
|   155 |      13 |   +142 | mach_port_insert_member |
|   150 |      13 |   +137 | _kernelrpc_mach_port_insert_member_trap |
|   121 |       9 |   +112 | non-virtual thunk to base::sequence_manager::internal::SequenceManagerImpl::SelectNextTask |
|   123 |      13 |   +110 | __CFRunLoopDoObservers |
|    92 |       6 |    +86 | _kernelrpc_mach_port_extract_member_trap |
|    92 |       6 |    +86 | mach_port_extract_member |
|    82 |      10 |    +72 | void partition_alloc::PartitionRoot::FreeInUnknownRoot< |
|    71 |       7 |    +64 | gl::GLContext::MakeCurrent |

### propias (hoja): más en el tramo lento (muestras de 1 ms; recuperado escalado a la misma duración)

|   150 |      13 |   +137 | _kernelrpc_mach_port_insert_member_trap |
|    92 |       6 |    +86 | _kernelrpc_mach_port_extract_member_trap |
|   108 |      22 |    +86 | <deduplicated_symbol> |
|    80 |       6 |    +74 | gpu::Scheduler::RunNextTask |
|    79 |       9 |    +70 | void partition_alloc::PartitionRoot::FreeInUnknownRoot< |
|    55 |       2 |    +53 | mach_absolute_time |
|    50 |       0 |    +50 | rx::ProgramExecutableMtl::setUniform3fv |
|    51 |       6 |    +45 | non-virtual thunk to base::sequence_manager::internal::SequenceManagerImpl::SelectNextTask |
|    42 |       3 |    +39 | base::sequence_manager::internal::TaskQueueImpl::TaskRunner::PostDelayedTask |
|    40 |       1 |    +39 | non-virtual thunk to base::sequence_manager::internal::ThreadControllerWithMessagePumpImpl::DoWork |
|    33 |       1 |    +32 | _pthread_mutex_firstfit_unlock_slow |
|    32 |       2 |    +30 | base::internal::RawPtrBackupRefImpl<false>::ReleaseInternal |
|    33 |       4 |    +29 | pthread_mutex_trylock |
|    30 |       4 |    +26 | base::internal::Invoker<base::internal::FunctorTraits<void  |
|    27 |       3 |    +24 | non-virtual thunk to base::sequence_manager::internal::SequenceManagerImpl::DidRunTask |
|    26 |       3 |    +23 | _pthread_mutex_firstfit_lock_slow |
|    23 |       1 |    +22 | void std::__Cr::__stable_sort[abi:sqn240000]<std::__Cr::_ClassicAlgPolicy, bool  |
|    21 |       0 |    +21 | base::MessagePumpCFRunLoopBase::EnterExitObserver |
|    27 |       7 |    +20 | tlv_get_addr |
|    20 |       2 |    +18 | invocation function for block in base::MessagePumpCFRunLoopBase::RunWorkSource |
|    17 |       0 |    +17 | gpu::Scheduler::SchedulingState::RunsBefore |
|    19 |       3 |    +16 | __CFRunLoopRun |
|    18 |       2 |    +16 | __CFRunLoopDoObservers |
|    16 |       0 |    +16 | GL_Uniform1f |
|    15 |       0 |    +15 | gl::EGLApiBase::eglGetCurrentContextFn |
|    15 |       0 |    +15 | gpu::GpuChannel::ExecuteDeferredRequest |
|    17 |       3 |    +14 | allocator_shim::internal::PartitionAllocFunctionsInternal< |
|    15 |       1 |    +14 | base::internal::RawPtrBackupRefImpl<true>::ReleaseInternal |
|    14 |       0 |    +14 | gpu::CommandBufferStub::ExecuteDeferredRequest |
|    17 |       4 |    +13 | _CFRelease |

## Chrome_ChildIOThread: lento 658/3656 activas (18 %), recuperado 88/3796 (2 %)

### inclusivas: más en el tramo lento (muestras de 1 ms; recuperado escalado a la misma duración)

|   658 |      85 |   +573 | _pthread_start |
|   658 |      85 |   +573 | base::sequence_manager::internal::ThreadControllerWithMessagePumpImpl::Run |
|   658 |      85 |   +573 | _pthread_body |
|   658 |      85 |   +573 | base::RunLoop::Run |
|   658 |      85 |   +573 | content:: |
|   658 |      85 |   +573 | base::Thread::ThreadMain |
|   658 |      85 |   +573 | thread_start |
|   658 |      85 |   +573 | base:: |
|   657 |      85 |   +572 | base::MessagePumpKqueue::Run |
|   474 |      74 |   +400 | non-virtual thunk to mojo::core:: |
|   453 |      69 |   +384 | mojo::core::Channel::TryDispatchMessage |
|   447 |      68 |   +379 | ipcz::msg::NodeMessageListener::OnTransportMessage |
|   416 |      61 |   +355 | ipcz::NodeLink::OnAcceptParcel |
|   411 |      59 |   +352 | ipcz::Router::AcceptInboundParcel |
|   394 |      59 |   +335 | mojo::core::ipcz_driver::MojoTrap::TrapEventHandler |
|   385 |      54 |   +331 | base::internal::Invoker<base::internal::FunctorTraits<void  |
|   183 |      24 |   +159 | mojo::MessageDispatcher::Accept |
|   162 |      19 |   +143 | mojo::InterfaceEndpointClient::HandleIncomingMessage |
|   153 |      21 |   +132 | MojoDestroyMessageIpcz |
|   126 |       1 |   +125 | non-virtual thunk to base::sequence_manager::internal::ThreadControllerWithMessagePumpImpl::DoWork |
|   136 |      20 |   +116 | ipcz::ParcelWrapper::~ParcelWrapper |
|   129 |      14 |   +115 | mojo::InterfaceEndpointClient::HandleIncomingMessageThunk::Accept |
|   120 |      19 |   +101 | mojo::core::ipcz_driver::Envelope::Close |
|   118 |      19 |    +99 | mach_port_deallocate |
|   116 |      19 |    +97 | _kernelrpc_mach_port_deallocate_trap |
|    90 |      13 |    +77 | gpu::mojom::GpuChannelStubDispatch::Accept |
|    76 |       2 |    +74 | <deduplicated_symbol> |
|    73 |      10 |    +63 | gpu::GpuChannelMessageFilter::FlushDeferredRequests |
|    55 |       0 |    +55 | gpu::mojom::GpuChannel_WaitForGetOffsetInRange_ProxyToResponder::Run |
|    52 |       6 |    +46 | gpu::Scheduler::ScheduleTasks |

### propias (hoja): más en el tramo lento (muestras de 1 ms; recuperado escalado a la misma duración)

|   116 |      19 |    +97 | _kernelrpc_mach_port_deallocate_trap |
|    37 |       4 |    +33 | base::MessagePumpKqueue::Run |
|    40 |       8 |    +32 | void* partition_alloc::PartitionRoot::Alloc< |
|    21 |       1 |    +20 | <deduplicated_symbol> |
|    20 |       3 |    +17 | base::internal::Invoker<base::internal::FunctorTraits<void  |
|    18 |       2 |    +16 | __psynch_mutexwait |
|    16 |       0 |    +16 | ipcz::Router::AcceptInboundParcel |
|    17 |       2 |    +15 | void partition_alloc::PartitionRoot::FreeInline< |
|    16 |       1 |    +15 | non-virtual thunk to base::sequence_manager::internal::ThreadControllerWithMessagePumpImpl::DoWork |
|    15 |       0 |    +15 | void partition_alloc::PartitionRoot::FreeInUnknownRoot< |
|    14 |       0 |    +14 | pthread_mutex_trylock |
|    12 |       1 |    +11 | mach_absolute_time |
|    12 |       1 |    +11 | ipcz::ParcelWrapper::~ParcelWrapper |
|    12 |       2 |    +10 | base::FeatureList::IsFeatureEnabled |
|    10 |       0 |    +10 | gpu::TaskGraph::Sequence::AddTask |
|    10 |       0 |    +10 | mojo::InterfaceEndpointClient::HandleIncomingMessage |
|    10 |       0 |    +10 | ipcz::Router::Put |
|    10 |       1 |     +9 | ipcz::Message::DeserializeFromTransport |
|     9 |       0 |     +9 | non-virtual thunk to base::sequence_manager::internal::SequenceManagerImpl::SelectNextTask |
|     8 |       0 |     +8 | __psynch_mutexdrop |
|     9 |       2 |     +7 | mojo::core::ipcz_driver::MojoTrap::TrapEventHandler |
|     8 |       1 |     +7 | non-virtual thunk to mojo::core:: |
|     7 |       0 |     +7 | gpu::GpuChannelMessageFilter::FlushDeferredRequests |
|     7 |       0 |     +7 | base::sequence_manager::internal::TaskQueueImpl::TaskRunner::PostDelayedTask |
|     7 |       0 |     +7 | mojo::InterfaceEndpointClient::HandleIncomingMessageThunk::Accept |
|     7 |       0 |     +7 | base::allocator::dispatcher::internal::DispatcherImpl<base::PoissonAllocationSampler>::FreeFn |
|     9 |       3 |     +6 | tlv_get_addr |
|     8 |       2 |     +6 | operator delete |
|     6 |       0 |     +6 | mojo::MessageHeaderValidator::Accept |
|     7 |       2 |     +5 | mojo::SimpleWatcher::ArmOrNotify |
