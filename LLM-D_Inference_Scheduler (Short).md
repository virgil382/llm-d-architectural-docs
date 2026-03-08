# LLM-D Inference Scheduler — Short Slide Deck

## Initialization Sequence
- Key points:
  - Runner registers plugin factories and calls `plugins.RegisterAllPlugins()`.
  - The Runner constructs runtime components: `Scheduler`, `ProfileHandler`, plugin instances.
  - Initialization ensures plugin factories and runner wiring are ready for per-request execution.
- Diagram:
  ![Initialization Sequence](diagrams/InitializationSequence.png)

---

## Director Sequence
- Key points:
  - Director orchestrates the per-request lifecycle: Admit → PrepareData → Scheduler → PreRequest → Dispatch.
  - Discovers candidate pods via `contracts.PodLocator`, converts them to scheduler endpoints, and applies admission checks.
  - Invokes request-control extension points and response hooks to allow plugins to mutate or observe requests/responses.
- Diagram:
  ![Director Sequence](diagrams/DirectorSequence.png)

---

## Scheduler Sequence
- Key points:
  - Scheduler runs `SchedulerProfile` pipelines: Filters → Scorers → Picker, as selected by the `ProfileHandler`.
  - Scorers return normalized scores aggregated by `WeightedScorer`; Pickers choose final endpoint(s).
  - `ProfileHandler.ProcessResults` consolidates profile outputs into a final `SchedulingResult` consumed by the Director.
- Diagram:
  ![Scheduler Sequence](diagrams/SchedulerSequence.png)

---

## Configuration Model & Class Diagram
- Key points:
  - Visualizes relationships between Director, Scheduler, SchedulerProfile, plugin types, and runtime models (`LLMRequest`, `SchedulingResult`).
  - Use to map configuration (plugin instances, profiles) to runtime wiring and interfaces.
  - Helpful reference when adding or locating plugin implementations in `pkg/plugins`.
- Diagram:
  ![Configuration model and class diagram](diagrams/CONFIG_MODEL.png)
